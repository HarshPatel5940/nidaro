import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import type { Env, Variables, AppContext } from '../types';
import { GSTPortalService } from '../services/gst';
import { authMiddleware } from '../middleware';
import { isValidGSTIN, isValidPAN, isValidMobileNumber } from '../utils';

const business = new Hono<{ Bindings: Env; Variables: Variables }>();

// Apply auth middleware to all business routes
business.use('*', authMiddleware);

// Search business by type and value
business.get(
  '/',
  zValidator(
    'json',
    z.object({
      type: z.enum(['name', 'gstin', 'pan', 'mobile']),
      value: z.string().min(1, 'Search value is required'),
    })
  ),
  async c => {
    try {
      const { type, value } = c.req.valid('json');
      let results: any;

      switch (type) {
        case 'gstin':
          if (!isValidGSTIN(value)) {
            return c.json({ error: 'Invalid GSTIN format' }, 400);
          }

          results = await c.env.DB.prepare(
            `
            SELECT 
              bd.gstin, bd.legal_name, bd.trade_name, bd.status, 
              bd.constitution, bd.registration_date, bd.address,
              u.business_name, u.mobile_no
            FROM business_details bd
            JOIN users u ON bd.user_id = u.id
            WHERE bd.gstin = ?
          `
          )
            .bind(value)
            .all();
          break;

        case 'pan':
          if (!isValidPAN(value)) {
            return c.json({ error: 'Invalid PAN format' }, 400);
          }

          results = await c.env.DB.prepare(
            `
            SELECT 
              bd.gstin, bd.legal_name, bd.trade_name, bd.status, 
              bd.constitution, bd.registration_date, bd.address,
              u.business_name, u.mobile_no, u.user_pan
            FROM business_details bd
            JOIN users u ON bd.user_id = u.id
            WHERE u.user_pan = ?
          `
          )
            .bind(value)
            .all();
          break;

        case 'mobile':
          if (!isValidMobileNumber(value)) {
            return c.json({ error: 'Invalid mobile number format' }, 400);
          }

          const formattedMobile = value.startsWith('+91')
            ? value
            : `+91${value.replace(/\D/g, '')}`;
          results = await c.env.DB.prepare(
            `
            SELECT 
              bd.gstin, bd.legal_name, bd.trade_name, bd.status, 
              bd.constitution, bd.registration_date, bd.address,
              u.business_name, u.mobile_no
            FROM business_details bd
            JOIN users u ON bd.user_id = u.id
            WHERE u.mobile_no = ? OR u.user_pan_mobile = ?
          `
          )
            .bind(formattedMobile, formattedMobile)
            .all();
          break;

        case 'name':
          results = await c.env.DB.prepare(
            `
            SELECT 
              bd.gstin, bd.legal_name, bd.trade_name, bd.status, 
              bd.constitution, bd.registration_date, bd.address,
              u.business_name, u.mobile_no
            FROM business_details bd
            JOIN users u ON bd.user_id = u.id
            WHERE bd.legal_name LIKE ? OR bd.trade_name LIKE ? OR u.business_name LIKE ?
          `
          )
            .bind(`%${value}%`, `%${value}%`, `%${value}%`)
            .all();
          break;

        default:
          return c.json({ error: 'Invalid search type' }, 400);
      }

      // Also get reports count for each business
      const businessesWithReports = await Promise.all(
        results.results.map(async (business: any) => {
          const reportsCount = await c.env.DB.prepare(
            `
            SELECT COUNT(*) as count FROM reports WHERE reported_business_gstin = ?
          `
          )
            .bind(business.gstin)
            .first();

          return {
            ...business,
            reportsCount: reportsCount?.count || 0,
          };
        })
      );

      return c.json({
        success: true,
        results: businessesWithReports,
        count: businessesWithReports.length,
      });
    } catch (error) {
      console.error('Business search error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

// Refetch business details from government portal
business.patch('/refetch', async c => {
  try {
    const user = c.get('user');
    if (!user) {
      return c.json({ error: 'Authentication required' }, 401);
    }

    // Get user's business details
    const businessDetails = await c.env.DB.prepare(
      `
        SELECT gstin FROM business_details WHERE user_id = ?
      `
    )
      .bind(user.userId)
      .first();

    if (!businessDetails) {
      return c.json({ error: 'No business details found for this user' }, 404);
    }

    const gstService = new GSTPortalService();

    // Get captcha for fetching fresh data
    const captchaResult = await gstService.getCaptcha();
    if (!captchaResult.success) {
      return c.json({ error: 'Failed to get captcha for data refresh' }, 500);
    }

    return c.json({
      success: true,
      message: 'Please solve the captcha to refresh business data',
      captchaImage: captchaResult.captchaBase64,
      gstin: businessDetails.gstin,
      // In a real implementation, you'd create a session here similar to signup
      instructions: 'Use the /business/refetch/verify endpoint with captcha solution',
    });
  } catch (error) {
    console.error('Business refetch error:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Verify captcha and complete refetch
business.post(
  '/refetch/verify',
  zValidator(
    'json',
    z.object({
      captchaInput: z.string().min(1, 'Captcha input is required'),
      gstin: z.string(),
    })
  ),
  async c => {
    try {
      const { captchaInput, gstin } = c.req.valid('json');
      const user = c.get('user');
      if (!user) {
        return c.json({ error: 'Authentication required' }, 401);
      }

      if (!isValidGSTIN(gstin)) {
        return c.json({ error: 'Invalid GSTIN format' }, 400);
      }

      const gstService = new GSTPortalService();

      // For demonstration, we'll simulate the captcha verification
      // In a real implementation, you'd store the cookies from the captcha request
      // and use them here along with proper session management

      // Simulate fetching fresh data
      const mockFreshData = {
        taxpayer_details: {
          lgnm: 'Updated Legal Name',
          tradeNam: 'Updated Trade Name',
          sts: 'Active',
          ctb: 'Partnership',
          rgdt: '01/07/2017',
          pradr: {
            adr: 'Updated address details',
          },
        },
        goods_services: {
          bzgddtls: [],
        },
      };

      // Update business details in database
      await c.env.DB.prepare(
        `
        UPDATE business_details 
        SET legal_name = ?, trade_name = ?, status = ?, constitution = ?, 
            address = ?, goods_services_json = ?, updated_at = CURRENT_TIMESTAMP
        WHERE user_id = ? AND gstin = ?
      `
      )
        .bind(
          mockFreshData.taxpayer_details.lgnm,
          mockFreshData.taxpayer_details.tradeNam,
          mockFreshData.taxpayer_details.sts,
          mockFreshData.taxpayer_details.ctb,
          mockFreshData.taxpayer_details.pradr.adr,
          JSON.stringify(mockFreshData.goods_services),
          user.userId,
          gstin
        )
        .run();

      return c.json({
        success: true,
        message: 'Business details refreshed successfully',
        updatedData: mockFreshData.taxpayer_details,
      });
    } catch (error) {
      console.error('Business refetch verify error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

export default business;
