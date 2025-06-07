import type { Context } from 'hono';

export interface Env {
  DB: D1Database;
  NIDARO_KV: KVNamespace;
  JWT_SECRET: string;
  TWILIO_ACCOUNT_SID: string;
  TWILIO_AUTH_TOKEN: string;
  TWILIO_VERIFY_SERVICE_SID: string;
}

export interface Variables {
  user?: {
    userId: string;
    businessName: string;
    mobileNo: string;
    isVerified: boolean;
  };
}

export type AppContext = Context<{ Bindings: Env; Variables: Variables }>;

export interface User {
  id: string;
  business_name: string;
  mobile_no: string;
  password_hash: string;
  verification_phase: number;
  is_verified: boolean;
  user_pan?: string;
  user_pan_name?: string;
  user_dob?: string;
  user_pan_mobile?: string;
  gstin?: string;
  created_at: string;
  updated_at: string;
}

export interface BusinessDetails {
  id: string;
  user_id: string;
  gstin: string;
  legal_name?: string;
  trade_name?: string;
  status?: string;
  constitution?: string;
  registration_date?: string;
  address?: string;
  nature_of_business?: string;
  goods_services_json?: string;
  created_at: string;
  updated_at: string;
}

export interface Report {
  id: string;
  reporter_id: string;
  reported_business_gstin: string;
  report_type: 'money' | 'non_money';
  title: string;
  description: string;
  evidence_json?: string;
  status: 'pending' | 'verified' | 'disputed';
  attestations_count: number;
  min_attestations_required: number;
  has_gov_dispute: boolean;
  created_at: string;
  updated_at: string;
}

export interface Attestation {
  id: string;
  report_id: string;
  attester_id: string;
  is_supporting: boolean;
  comments?: string;
  created_at: string;
}

export interface OTPSession {
  id: string;
  mobile_no: string;
  otp_code: string;
  purpose: 'login' | 'signup_step1' | 'signup_step2';
  expires_at: string;
  is_verified: boolean;
  created_at: string;
}

export interface CaptchaSession {
  id: string;
  session_id: string;
  captcha_image_base64: string;
  purpose: 'pan_to_gst' | 'gst_to_details';
  context_data?: string;
  expires_at: string;
  created_at: string;
}
