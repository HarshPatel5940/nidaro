import type { Env } from '../types';

export class TwilioService {
  private accountSid: string;
  private authToken: string;
  private verifyServiceSid: string;

  constructor(env: Env) {
    this.accountSid = env.TWILIO_ACCOUNT_SID;
    this.authToken = env.TWILIO_AUTH_TOKEN;
    this.verifyServiceSid = env.TWILIO_VERIFY_SERVICE_SID;
  }

  async sendOTP(mobileNo: string): Promise<{ success: boolean; sid?: string; error?: string }> {
    try {
      const url = `https://verify.twilio.com/v2/Services/${this.verifyServiceSid}/Verifications`;

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          Authorization: `Basic ${btoa(`${this.accountSid}:${this.authToken}`)}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          To: mobileNo,
          Channel: 'sms',
        }),
      });

      const result = (await response.json()) as any;

      if (response.ok) {
        return { success: true, sid: result.sid };
      } else {
        return {
          success: false,
          error: result.message || 'Failed to send OTP',
        };
      }
    } catch (error) {
      return { success: false, error: 'Network error occurred' };
    }
  }

  async verifyOTP(mobileNo: string, code: string): Promise<{ success: boolean; error?: string }> {
    try {
      const url = `https://verify.twilio.com/v2/Services/${this.verifyServiceSid}/VerificationCheck`;

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          Authorization: `Basic ${btoa(`${this.accountSid}:${this.authToken}`)}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          To: mobileNo,
          Code: code,
        }),
      });

      const result = (await response.json()) as any;

      if (response.ok && result.status === 'approved') {
        return { success: true };
      } else {
        return { success: false, error: result.message || 'Invalid OTP' };
      }
    } catch (error) {
      return { success: false, error: 'Network error occurred' };
    }
  }
}
