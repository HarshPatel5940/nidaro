import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import type { Env, Variables, AppContext } from '../types';
import { authMiddleware } from '../middleware';
import { generateId, isValidGSTIN } from '../utils';

const reports = new Hono<{ Bindings: Env; Variables: Variables }>();

reports.use('*', authMiddleware);

reports.post(
  '/',
  zValidator(
    'json',
    z.object({
      reportedBusinessGstin: z.string().min(1, 'Business GSTIN is required'),
      reportType: z.enum(['money', 'non_money']),
      title: z.string().min(1, 'Title is required'),
      description: z.string().min(10, 'Description must be at least 10 characters'),
      evidence: z
        .array(
          z.object({
            type: z.enum(['document', 'image', 'url']),
            url: z.string().url(),
            description: z.string().optional(),
          })
        )
        .optional(),
    })
  ),
  async c => {
    try {
      const { reportedBusinessGstin, reportType, title, description, evidence } =
        c.req.valid('json');
      const user = c.get('user');
      if (!user) {
        return c.json({ error: 'Authentication required' }, 401);
      }

      if (!isValidGSTIN(reportedBusinessGstin)) {
        return c.json({ error: 'Invalid GSTIN format' }, 400);
      }

      const business = await c.env.DB.prepare(
        `
        SELECT gstin FROM business_details WHERE gstin = ?
      `
      )
        .bind(reportedBusinessGstin)
        .first();

      if (!business) {
        return c.json({ error: 'Business not found in our database' }, 404);
      }

      const userBusiness = await c.env.DB.prepare(
        `
        SELECT gstin FROM business_details WHERE user_id = ? AND gstin = ?
      `
      )
        .bind(user.userId, reportedBusinessGstin)
        .first();

      if (userBusiness) {
        return c.json({ error: 'You cannot report your own business' }, 400);
      }

      const reportId = generateId();
      await c.env.DB.prepare(
        `
        INSERT INTO reports (
          id, reporter_id, reported_business_gstin, report_type, 
          title, description, evidence_json, status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')
      `
      )
        .bind(
          reportId,
          user.userId,
          reportedBusinessGstin,
          reportType,
          title,
          description,
          JSON.stringify(evidence || [])
        )
        .run();

      return c.json({
        success: true,
        message: 'Report created successfully',
        reportId,
        status: 'pending',
      });
    } catch (error) {
      console.error('Create report error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

reports.get('/my-reports', async c => {
  try {
    const user = c.get('user');
    if (!user) {
      return c.json({ error: 'Authentication required' }, 401);
    }

    const reports = await c.env.DB.prepare(
      `
        SELECT 
          r.*, 
          bd.legal_name as reported_business_name,
          bd.trade_name as reported_trade_name
        FROM reports r
        JOIN business_details bd ON r.reported_business_gstin = bd.gstin
        WHERE r.reporter_id = ?
        ORDER BY r.created_at DESC
      `
    )
      .bind(user.userId)
      .all();

    return c.json({
      success: true,
      reports: reports.results.map((report: any) => ({
        ...report,
        evidence_json: JSON.parse(report.evidence_json || '[]'),
      })),
    });
  } catch (error) {
    console.error('Get my reports error:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

reports.get('/on-my-business', async c => {
  try {
    const user = c.get('user');
    if (!user) {
      return c.json({ error: 'Authentication required' }, 401);
    }

    const userBusiness = await c.env.DB.prepare(
      `
        SELECT gstin FROM business_details WHERE user_id = ?
      `
    )
      .bind(user.userId)
      .first();

    if (!userBusiness) {
      return c.json({ success: true, reports: [] });
    }

    const reports = await c.env.DB.prepare(
      `
        SELECT 
          r.*, 
          u.business_name as reporter_business_name
        FROM reports r
        JOIN users u ON r.reporter_id = u.id
        WHERE r.reported_business_gstin = ?
        ORDER BY r.created_at DESC
      `
    )
      .bind(userBusiness.gstin)
      .all();

    return c.json({
      success: true,
      reports: reports.results.map((report: any) => ({
        ...report,
        evidence_json: JSON.parse(report.evidence_json || '[]'),
      })),
    });
  } catch (error) {
    console.error('Get reports on my business error:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

reports.get('/business/:gstin', async c => {
  try {
    const gstin = c.req.param('gstin');

    if (!isValidGSTIN(gstin)) {
      return c.json({ error: 'Invalid GSTIN format' }, 400);
    }

    const reports = await c.env.DB.prepare(
      `
        SELECT 
          r.id, r.report_type, r.title, r.description, r.status, 
          r.attestations_count, r.has_gov_dispute, r.created_at,
          u.business_name as reporter_business_name
        FROM reports r
        JOIN users u ON r.reporter_id = u.id
        WHERE r.reported_business_gstin = ? AND r.status IN ('verified', 'disputed')
        ORDER BY r.created_at DESC
      `
    )
      .bind(gstin)
      .all();

    return c.json({
      success: true,
      reports: reports.results,
    });
  } catch (error) {
    console.error('Get business reports error:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

reports.post(
  '/:reportId/attest',
  zValidator(
    'json',
    z.object({
      isSupporting: z.boolean(),
      comments: z.string().optional(),
    })
  ),
  async c => {
    try {
      const reportId = c.req.param('reportId');
      const { isSupporting, comments } = c.req.valid('json');
      const user = c.get('user');
      if (!user) {
        return c.json({ error: 'Authentication required' }, 401);
      }

      const report = await c.env.DB.prepare(
        `
        SELECT * FROM reports WHERE id = ?
      `
      )
        .bind(reportId)
        .first();

      if (!report) {
        return c.json({ error: 'Report not found' }, 404);
      }

      if (report.reporter_id === user.userId) {
        return c.json({ error: 'You cannot attest to your own report' }, 400);
      }

      const existingAttestation = await c.env.DB.prepare(
        `
        SELECT id FROM attestations WHERE report_id = ? AND attester_id = ?
      `
      )
        .bind(reportId, user.userId)
        .first();

      if (existingAttestation) {
        return c.json({ error: 'You have already attested to this report' }, 400);
      }

      const attestationId = generateId();
      await c.env.DB.prepare(
        `
        INSERT INTO attestations (id, report_id, attester_id, is_supporting, comments)
        VALUES (?, ?, ?, ?, ?)
      `
      )
        .bind(attestationId, reportId, user.userId, isSupporting, comments || null)
        .run();

      await c.env.DB.prepare(
        `
        UPDATE reports 
        SET attestations_count = attestations_count + 1,
            status = CASE 
              WHEN attestations_count + 1 >= min_attestations_required THEN 'verified'
              ELSE status 
            END,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `
      )
        .bind(reportId)
        .run();

      return c.json({
        success: true,
        message: 'Attestation recorded successfully',
        attestationId,
      });
    } catch (error) {
      console.error('Attest report error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

reports.patch(
  '/:reportId/dispute',
  zValidator(
    'json',
    z.object({
      reason: z.string().min(10, 'Dispute reason must be at least 10 characters'),
    })
  ),
  async c => {
    try {
      const reportId = c.req.param('reportId');
      const { reason } = c.req.valid('json');
      const user = c.get('user');
      if (!user) {
        return c.json({ error: 'Authentication required' }, 401);
      }

      const report = await c.env.DB.prepare(
        `
        SELECT * FROM reports WHERE id = ? AND status = 'verified'
      `
      )
        .bind(reportId)
        .first();

      if (!report) {
        return c.json({ error: 'Report not found or not verified' }, 404);
      }

      const businessOwner = await c.env.DB.prepare(
        `
        SELECT user_id FROM business_details WHERE gstin = ?
      `
      )
        .bind(report.reported_business_gstin)
        .first();

      if (!businessOwner || businessOwner.user_id !== user.userId) {
        return c.json({ error: 'Only the reported business owner can dispute this report' }, 403);
      }

      await c.env.DB.prepare(
        `
        UPDATE reports 
        SET has_gov_dispute = true, status = 'disputed', updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `
      )
        .bind(reportId)
        .run();

      await c.env.NIDARO_KV.put(
        `dispute:${reportId}`,
        JSON.stringify({
          reportId,
          disputedBy: user.userId,
          reason,
          timestamp: new Date().toISOString(),
        })
      );

      return c.json({
        success: true,
        message: 'Report disputed successfully. It will be reviewed by authorities.',
        status: 'disputed',
      });
    } catch (error) {
      console.error('Dispute report error:', error);
      return c.json({ error: 'Internal server error' }, 500);
    }
  }
);

reports.get('/:reportId', async c => {
  try {
    const reportId = c.req.param('reportId');

    const report = await c.env.DB.prepare(
      `
        SELECT 
          r.*, 
          bd.legal_name as reported_business_name,
          bd.trade_name as reported_trade_name,
          u.business_name as reporter_business_name
        FROM reports r
        JOIN business_details bd ON r.reported_business_gstin = bd.gstin
        JOIN users u ON r.reporter_id = u.id
        WHERE r.id = ?
      `
    )
      .bind(reportId)
      .first();

    if (!report) {
      return c.json({ error: 'Report not found' }, 404);
    }

    const attestations = await c.env.DB.prepare(
      `
        SELECT 
          a.is_supporting, a.comments, a.created_at,
          u.business_name as attester_business_name
        FROM attestations a
        JOIN users u ON a.attester_id = u.id
        WHERE a.report_id = ?
        ORDER BY a.created_at DESC
      `
    )
      .bind(reportId)
      .all();

    return c.json({
      success: true,
      report: {
        ...report,
        evidence_json: JSON.parse((report as any).evidence_json || '[]'),
        attestations: attestations.results,
      },
    });
  } catch (error) {
    console.error('Get report details error:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

export default reports;
