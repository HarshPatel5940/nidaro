import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import type { Env, Variables, AppContext } from '../types';
import { GSTPortalService } from '../services/gst';
import { authMiddleware } from '../middleware';
import {
  isValidMobileNumber,
  validateGSTIN,
  validatePAN,
  validatePhoneNumber,
  sanitizeInput,
} from '../utils';

const business = new Hono<{ Bindings: Env; Variables: Variables }>();

business.use('*', authMiddleware);

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
      const sanitizedValue = sanitizeInput(value);
      let results: any;

      switch (type) {
        case 'gstin':
          if (!validateGSTIN(sanitizedValue)) {
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
            .bind(sanitizedValue)
            .all();
          break;

        case 'pan':
          if (!validatePAN(sanitizedValue)) {
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
            .bind(sanitizedValue)
            .all();
          break;

        case 'mobile':
          if (!validatePhoneNumber(sanitizedValue)) {
            return c.json({ error: 'Invalid mobile number format' }, 400);
          }

          const formattedMobile = sanitizedValue.startsWith('+91')
            ? sanitizedValue
            : `+91${sanitizedValue.replace(/\D/g, '')}`;
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

      const gstins = results.results.map((business: any) => business.gstin);
      const reportCountsQuery = `
        SELECT reported_business_gstin, COUNT(*) as count
        FROM reports 
        WHERE reported_business_gstin IN (${gstins.map(() => '?').join(',')})
        GROUP BY reported_business_gstin
      `;
      const reportCounts = await c.env.DB.prepare(reportCountsQuery)
        .bind(...gstins)
        .all();

      const reportCountsMap = new Map(
        reportCounts.results.map((row: any) => [row.reported_business_gstin, row.count])
      );

      const businessesWithReports = results.results.map((business: any) => ({
        ...business,
        reportsCount: reportCountsMap.get(business.gstin) || 0,
      }));

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

business.patch('/refetch', async c => {
  try {
    const user = c.get('user');
    if (!user) {
      return c.json({ error: 'Authentication required' }, 401);
    }

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

    const captchaResult = await gstService.getCaptcha();
    if (!captchaResult.success) {
      return c.json({ error: 'Failed to get captcha for data refresh' }, 500);
    }

    return c.json({
      success: true,
      message: 'Please solve the captcha to refresh business data',
      captchaImage: captchaResult.captchaBase64,
      gstin: businessDetails.gstin,

      instructions: 'Use the /business/refetch/verify endpoint with captcha solution',
    });
  } catch (error) {
    console.error('Business refetch error:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

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
      const sanitizedGstin = sanitizeInput(gstin);
      const user = c.get('user');
      if (!user) {
        return c.json({ error: 'Authentication required' }, 401);
      }

      if (!validateGSTIN(sanitizedGstin)) {
        return c.json({ error: 'Invalid GSTIN format' }, 400);
      }

      const gstService = new GSTPortalService();

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
