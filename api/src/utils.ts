import type { Context } from 'hono';
import type { Env } from './types';

export function generateId(): string {
  return Math.random().toString(36).substring(2) + Date.now().toString(36);
}

export function isValidMobileNumber(mobile: string): boolean {
  const mobileRegex = /^(\+91|91)?[6-9]\d{9}$/;
  return mobileRegex.test(mobile);
}

export function formatMobileNumber(mobile: string): string {
  // Remove any non-digit characters and ensure proper format
  const cleaned = mobile.replace(/\D/g, '');
  if (cleaned.startsWith('91') && cleaned.length === 12) {
    return `+${cleaned}`;
  } else if (cleaned.length === 10) {
    return `+91${cleaned}`;
  }
  return mobile;
}

export function isValidPAN(pan: string): boolean {
  const panRegex = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
  return panRegex.test(pan);
}

export function isValidGSTIN(gstin: string): boolean {
  const gstinRegex = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
  return gstinRegex.test(gstin);
}

export async function setSecureCookie(
  c: Context,
  name: string,
  value: string,
  maxAge = 7 * 24 * 60 * 60
) {
  const cookieOptions = [
    `${name}=${value}`,
    `Max-Age=${maxAge}`,
    'Path=/',
    'HttpOnly',
    'SameSite=Strict',
  ];

  // Add Secure flag in production
  const url = new URL(c.req.url);
  if (url.protocol === 'https:') {
    cookieOptions.push('Secure');
  }

  c.header('Set-Cookie', cookieOptions.join('; '));
}

export function getCookie(c: Context, name: string): string | undefined {
  const cookieHeader = c.req.header('cookie');
  if (!cookieHeader) return undefined;

  const cookies = cookieHeader.split(';').map(cookie => cookie.trim());
  const targetCookie = cookies.find(cookie => cookie.startsWith(`${name}=`));

  return targetCookie ? targetCookie.split('=')[1] : undefined;
}

export function clearCookie(c: Context, name: string) {
  c.header('Set-Cookie', `${name}=; Max-Age=0; Path=/; HttpOnly`);
}

export async function hashPassword(password: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(password);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  const hashedInput = await hashPassword(password);
  return hashedInput === hash;
}

export function createJWT(payload: any, secret: string): string {
  const header = { alg: 'HS256', typ: 'JWT' };
  const encodedHeader = btoa(JSON.stringify(header));
  const encodedPayload = btoa(JSON.stringify(payload));

  const signature = btoa(`${encodedHeader}.${encodedPayload}.${secret}`);

  return `${encodedHeader}.${encodedPayload}.${signature}`;
}

export function verifyJWT(token: string, secret: string): any {
  try {
    const [encodedHeader, encodedPayload, signature] = token.split('.');
    const expectedSignature = btoa(`${encodedHeader}.${encodedPayload}.${secret}`);

    if (signature !== expectedSignature) {
      throw new Error('Invalid signature');
    }

    return JSON.parse(atob(encodedPayload));
  } catch (error) {
    throw new Error('Invalid token');
  }
}

export function addExpiryTime(minutes: number): string {
  return new Date(Date.now() + minutes * 60 * 1000).toISOString();
}

export function isExpired(expiryTime: string): boolean {
  return new Date() > new Date(expiryTime);
}
