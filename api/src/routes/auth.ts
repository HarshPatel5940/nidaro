import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import type { Env, Variables } from '../types';
import { TwilioService } from '../services/twilio';
import { GSTPortalService } from '../services/gst';
import {
  generateId,
  isValidMobileNumber,
  formatMobileNumber,
  hashPassword,
  verifyPassword,
  createJWT,
  setSecureCookie,
  addExpiryTime,
  isExpired,
  validateGSTIN,
  validatePAN,
  sanitizeInput,
} from '../utils';

const auth = new Hono<{ Bindings: Env; Variables: Variables }>();

auth.post(
  '/login/mobile/otp',
  zValidator(
    'json',
    z.object({
      mobileNo: z.string().min(10, 'Mobile number must be at least 10 digits'),
    })
  ),
  async c => {
    try {
      const { mobileNo } = c.req.valid('json');

      const sanitizedMobile = sanitizeInput(mobileNo);

      if (!isValidMobileNumber(sanitizedMobile)) {
        return c.json({ error: 'Invalid mobile number format' }, 400);
      }

      const formattedMobile = formatMobileNumber(sanitizedMobile);

      const user = await c.env.DB.prepare('SELECT id, mobile_no FROM users WHERE mobile_no = ?')
        .bind(formattedMobile)
        .first();

      if (!user) {
        return c.json({ error: 'User not found. Please sign up first.' }, 404);
      }

      const twilioService = new TwilioService(c.env);
      const result = await twilioService.sendOTP(formattedMobile);

      if (!result.success) {
        return c.json({ error: result.error }, 500);
      }

      return c.json({
        success: true,
        message: 'OTP sent successfully',
        mobileNo: formattedMobile,
      });
    } catch (error) {
      console.error('Login OTP error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

auth.post(
  '/login/mobile/verify',
  zValidator(
    'json',
    z.object({
      mobileNo: z.string(),
      otp: z.string().length(6, 'OTP must be 6 digits'),
    })
  ),
  async c => {
    try {
      const { mobileNo, otp } = c.req.valid('json');
      const formattedMobile = formatMobileNumber(mobileNo);

      const user = await c.env.DB.prepare('SELECT * FROM users WHERE mobile_no = ?')
        .bind(formattedMobile)
        .first();

      if (!user) {
        return c.json({ error: 'User not found' }, 404);
      }

      const twilioService = new TwilioService(c.env);
      const result = await twilioService.verifyOTP(formattedMobile, otp);

      if (!result.success) {
        return c.json({ error: result.error || 'Invalid OTP' }, 400);
      }

      const token = await createJWT(
        {
          userId: user.id,
          mobileNo: user.mobile_no,
          businessName: user.business_name,
          exp: Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60,
        },
        c.env.JWT_SECRET
      );

      await setSecureCookie(c, 'auth_token', token);

      return c.json({
        success: true,
        message: 'Login successful',
        user: {
          id: user.id,
          businessName: user.business_name,
          mobileNo: user.mobile_no,
          verificationPhase: user.verification_phase,
          isVerified: user.is_verified,
        },
      });
    } catch (error) {
      console.error('Login verify error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

auth.post(
  '/signup/step/1',
  zValidator(
    'json',
    z.object({
      businessName: z.string().min(1, 'Business name is required'),
      mobileNo: z.string().min(10, 'Mobile number must be at least 10 digits'),
      password: z.string().min(6, 'Password must be at least 6 characters'),
    })
  ),
  async c => {
    try {
      const { businessName, mobileNo, password } = c.req.valid('json');

      if (!isValidMobileNumber(mobileNo)) {
        return c.json({ error: 'Invalid mobile number format' }, 400);
      }

      const formattedMobile = formatMobileNumber(mobileNo);

      const existingUser = await c.env.DB.prepare(
        'SELECT id, verification_phase FROM users WHERE mobile_no = ?'
      )
        .bind(formattedMobile)
        .first();

      if (existingUser) {
        if ((existingUser as any).verification_phase > 1) {
          return c.json(
            {
              error: 'User already exists and has completed mobile verification',
              phase: (existingUser as any).verification_phase,
            },
            409
          );
        }
      }

      const twilioService = new TwilioService(c.env);
      const result = await twilioService.sendOTP(formattedMobile);

      if (!result.success) {
        return c.json({ error: result.error }, 500);
      }

      const signupData = {
        businessName,
        mobileNo: formattedMobile,
        password: await hashPassword(password),
        timestamp: Date.now(),
      };

      await c.env.NIDARO_KV.put(`signup:${formattedMobile}`, JSON.stringify(signupData), {
        expirationTtl: 600,
      });

      return c.json({
        success: true,
        message: 'OTP sent successfully',
        mobileNo: formattedMobile,
      });
    } catch (error) {
      console.error('Signup step 1 error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

auth.post(
  '/signup/step/1/verify',
  zValidator(
    'json',
    z.object({
      mobileNo: z.string(),
      otp: z.string().length(6, 'OTP must be 6 digits'),
    })
  ),
  async c => {
    try {
      const { mobileNo, otp } = c.req.valid('json');
      const formattedMobile = formatMobileNumber(mobileNo);

      const signupDataStr = await c.env.NIDARO_KV.get(`signup:${formattedMobile}`);
      if (!signupDataStr) {
        return c.json({ error: 'Signup session expired. Please start again.' }, 400);
      }

      const signupData = JSON.parse(signupDataStr);

      const twilioService = new TwilioService(c.env);
      const result = await twilioService.verifyOTP(formattedMobile, otp);

      if (!result.success) {
        return c.json({ error: result.error || 'Invalid OTP' }, 400);
      }

      let user = await c.env.DB.prepare('SELECT id FROM users WHERE mobile_no = ?')
        .bind(formattedMobile)
        .first();

      if (!user) {
        const userId = generateId();
        await c.env.DB.prepare(
          `
          INSERT INTO users (id, business_name, mobile_no, password_hash, verification_phase)
          VALUES (?, ?, ?, ?, 2)
        `
        )
          .bind(userId, signupData.businessName, formattedMobile, signupData.password)
          .run();

        user = { id: userId };
      } else {
        await c.env.DB.prepare(
          `
          UPDATE users 
          SET business_name = ?, password_hash = ?, verification_phase = 2, updated_at = CURRENT_TIMESTAMP
          WHERE mobile_no = ?
        `
        )
          .bind(signupData.businessName, signupData.password, formattedMobile)
          .run();
      }

      await c.env.NIDARO_KV.delete(`signup:${formattedMobile}`);

      return c.json({
        success: true,
        message: 'Mobile number verified successfully. Please proceed to step 2.',
        nextStep: '/signup/step/2',
        userId: user.id,
      });
    } catch (error) {
      console.error('Signup step 1 verify error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

auth.post(
  '/signup/step/2',
  zValidator(
    'json',
    z.object({
      userPan: z.string().length(10, 'PAN must be 10 characters'),
      userPanName: z.string().min(1, 'PAN holder name is required'),
      userDOB: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format'),
      userPanMob: z.string().min(10, 'Mobile number is required'),
    })
  ),
  async c => {
    try {
      const { userPan, userPanName, userDOB, userPanMob } = c.req.valid('json');
      const sanitizedPan = sanitizeInput(userPan);

      if (!validatePAN(sanitizedPan)) {
        return c.json({ error: 'Invalid PAN format' }, 400);
      }

      const sessionId = generateId();
      const panVerificationData = {
        userPan,
        userPanName,
        userDOB,
        userPanMob,
        step: 'pan_verification_p1',
        expiresAt: addExpiryTime(15),
      };

      await c.env.NIDARO_KV.put(
        `pan_verification:${sessionId}`,
        JSON.stringify(panVerificationData),
        { expirationTtl: 900 }
      );

      return c.json({
        success: true,
        message: 'PAN details received. Please verify with OTP.',
        sessionId,
        nextStep: '/signup/step/2/verify',
      });
    } catch (error) {
      console.error('Signup step 2 error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

auth.post(
  '/signup/step/2/verify',
  zValidator(
    'json',
    z.object({
      sessionId: z.string(),
      verificationCode: z.string().min(1, 'Verification code is required'),
    })
  ),
  async c => {
    try {
      const { sessionId, verificationCode } = c.req.valid('json');

      const dataStr = await c.env.NIDARO_KV.get(`pan_verification:${sessionId}`);
      if (!dataStr) {
        return c.json({ error: 'Session expired or invalid' }, 400);
      }

      const panData = JSON.parse(dataStr);

      if (isExpired(panData.expiresAt)) {
        await c.env.NIDARO_KV.delete(`pan_verification:${sessionId}`);
        return c.json({ error: 'Session expired' }, 400);
      }

      if (!/^\d{6}$/.test(verificationCode)) {
        return c.json({ error: 'Invalid verification code format' }, 400);
      }

      await c.env.DB.prepare(
        `
        UPDATE users 
        SET user_pan = ?, user_pan_name = ?, user_dob = ?, user_pan_mobile = ?, 
            verification_phase = 3, updated_at = CURRENT_TIMESTAMP
        WHERE mobile_no = ?
      `
      )
        .bind(
          panData.userPan,
          panData.userPanName,
          panData.userDOB,
          panData.userPanMob,
          panData.userPanMob
        )
        .run();

      await c.env.NIDARO_KV.delete(`pan_verification:${sessionId}`);

      return c.json({
        success: true,
        message: 'PAN verification completed. Please proceed to step 3.',
        nextStep: '/signup/step/3',
      });
    } catch (error) {
      console.error('Signup step 2 verify error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

auth.post(
  '/signup/step/3',
  zValidator(
    'json',
    z.object({
      userPan: z.string().length(10, 'PAN must be 10 characters'),
    })
  ),
  async c => {
    try {
      const { userPan } = c.req.valid('json');
      const sanitizedPan = sanitizeInput(userPan);

      if (!validatePAN(sanitizedPan)) {
        return c.json({ error: 'Invalid PAN format' }, 400);
      }

      const gstService = new GSTPortalService();
      const captchaResult = await gstService.getCaptcha();

      if (!captchaResult.success) {
        return c.json({ error: captchaResult.error }, 500);
      }

      const sessionId = generateId();
      const captchaSession = {
        sessionId,
        purpose: 'pan_to_gst',
        contextData: JSON.stringify({ userPan }),
        cookies: captchaResult.cookies,
        expiresAt: addExpiryTime(10),
      };

      await c.env.DB.prepare(
        `
        INSERT INTO captcha_sessions (id, session_id, captcha_image_base64, purpose, context_data, expires_at)
        VALUES (?, ?, ?, ?, ?, ?)
      `
      )
        .bind(
          generateId(),
          sessionId,
          captchaResult.captchaBase64,
          'pan_to_gst',
          JSON.stringify({ userPan, cookies: captchaResult.cookies }),
          captchaSession.expiresAt
        )
        .run();

      return c.json({
        success: true,
        message: 'Please solve the captcha to get GSTIN details',
        sessionId,
        captchaImage: captchaResult.captchaBase64,
        nextStep: '/signup/step/4',
      });
    } catch (error) {
      console.error('Signup step 3 error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

auth.post(
  '/signup/step/4',
  zValidator(
    'json',
    z.object({
      sessionId: z.string(),
      captchaInput: z.string().min(1, 'Captcha input is required'),
    })
  ),
  async c => {
    try {
      const { sessionId, captchaInput } = c.req.valid('json');

      const captchaSession = await c.env.DB.prepare(
        `
        SELECT * FROM captcha_sessions 
        WHERE session_id = ? AND purpose = 'pan_to_gst'
      `
      )
        .bind(sessionId)
        .first();

      if (!captchaSession) {
        return c.json({ error: 'Invalid session' }, 400);
      }

      if (isExpired((captchaSession as any).expires_at)) {
        await c.env.DB.prepare('DELETE FROM captcha_sessions WHERE session_id = ?')
          .bind(sessionId)
          .run();
        return c.json({ error: 'Session expired' }, 400);
      }

      const contextData = JSON.parse((captchaSession as any).context_data);
      const gstService = new GSTPortalService();

      const panResult = await gstService.queryPanToGst(
        contextData.userPan,
        captchaInput,
        contextData.cookies
      );

      if (!panResult.success) {
        return c.json({ error: panResult.error || 'Failed to fetch GSTIN' }, 400);
      }

      const gstinResList = panResult.data?.gstinResList || [];
      if (gstinResList.length === 0) {
        return c.json({ error: 'No GSTIN found for this PAN' }, 404);
      }

      const gstin = gstinResList[0].gstin;

      const newCaptchaResult = await gstService.getCaptcha();
      if (!newCaptchaResult.success) {
        return c.json({ error: 'Failed to get GST details captcha' }, 500);
      }

      const newSessionId = generateId();
      await c.env.DB.prepare(
        `
        INSERT INTO captcha_sessions (id, session_id, captcha_image_base64, purpose, context_data, expires_at)
        VALUES (?, ?, ?, ?, ?, ?)
      `
      )
        .bind(
          generateId(),
          newSessionId,
          newCaptchaResult.captchaBase64,
          'gst_to_details',
          JSON.stringify({
            gstin,
            userPan: contextData.userPan,
            cookies: newCaptchaResult.cookies,
          }),
          addExpiryTime(10)
        )
        .run();

      await c.env.DB.prepare('DELETE FROM captcha_sessions WHERE session_id = ?')
        .bind(sessionId)
        .run();

      return c.json({
        success: true,
        message: 'GSTIN found! Please solve the captcha to get complete business details.',
        gstin,
        sessionId: newSessionId,
        captchaImage: newCaptchaResult.captchaBase64,
        nextStep: '/signup/step/5',
      });
    } catch (error) {
      console.error('Signup step 4 error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

auth.post(
  '/signup/step/5',
  zValidator(
    'json',
    z.object({
      sessionId: z.string(),
      captchaInput: z.string().min(1, 'Captcha input is required'),
    })
  ),
  async c => {
    try {
      const { sessionId, captchaInput } = c.req.valid('json');

      const captchaSession = await c.env.DB.prepare(
        `
        SELECT * FROM captcha_sessions 
        WHERE session_id = ? AND purpose = 'gst_to_details'
      `
      )
        .bind(sessionId)
        .first();

      if (!captchaSession) {
        return c.json({ error: 'Invalid session' }, 400);
      }

      if (isExpired((captchaSession as any).expires_at)) {
        await c.env.DB.prepare('DELETE FROM captcha_sessions WHERE session_id = ?')
          .bind(sessionId)
          .run();
        return c.json({ error: 'Session expired' }, 400);
      }

      const contextData = JSON.parse((captchaSession as any).context_data);
      const gstService = new GSTPortalService();

      const taxpayerResult = await gstService.getTaxpayerDetails(
        contextData.gstin,
        captchaInput,
        contextData.cookies
      );

      if (!taxpayerResult.success) {
        return c.json({ error: taxpayerResult.error || 'Failed to fetch business details' }, 400);
      }

      const goodsServicesResult = await gstService.getGoodsServices(
        contextData.gstin,
        contextData.cookies
      );

      const businessData = {
        taxpayer_details: taxpayerResult.data,
        goods_services: goodsServicesResult.success ? goodsServicesResult.data : null,
      };

      await c.env.DB.prepare(
        `
        UPDATE users 
        SET gstin = ?, verification_phase = 6, is_verified = true, updated_at = CURRENT_TIMESTAMP
        WHERE user_pan = ?
      `
      )
        .bind(contextData.gstin, contextData.userPan)
        .run();

      const user = await c.env.DB.prepare('SELECT id FROM users WHERE user_pan = ?')
        .bind(contextData.userPan)
        .first();

      if (user) {
        await c.env.DB.prepare(
          `
          INSERT INTO business_details (
            id, user_id, gstin, legal_name, trade_name, status, constitution, 
            registration_date, address, goods_services_json
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `
        )
          .bind(
            generateId(),
            user.id,
            contextData.gstin,
            businessData.taxpayer_details?.lgnm || '',
            businessData.taxpayer_details?.tradeNam || '',
            businessData.taxpayer_details?.sts || '',
            businessData.taxpayer_details?.ctb || '',
            businessData.taxpayer_details?.rgdt || '',
            businessData.taxpayer_details?.pradr?.adr || '',
            JSON.stringify(businessData.goods_services)
          )
          .run();
      }

      await c.env.DB.prepare('DELETE FROM captcha_sessions WHERE session_id = ?')
        .bind(sessionId)
        .run();

      return c.json({
        success: true,
        message: 'Registration completed successfully! You can now login.',
        businessDetails: {
          gstin: contextData.gstin,
          legalName: businessData.taxpayer_details?.lgnm,
          tradeName: businessData.taxpayer_details?.tradeNam,
          status: businessData.taxpayer_details?.sts,
          registrationDate: businessData.taxpayer_details?.rgdt,
        },
      });
    } catch (error) {
      console.error('Signup step 5 error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

export default auth;
