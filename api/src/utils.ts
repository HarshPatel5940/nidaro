import type { Context } from 'hono';
import type { Env } from './types';

export function generateId(): string {
  return crypto.randomUUID();
}

export function isValidMobileNumber(mobile: string): boolean {
  const mobileRegex = /^(\+91|91)?[6-9]\d{9}$/;
  return mobileRegex.test(mobile);
}

export function formatMobileNumber(mobile: string): string {
  const cleaned = mobile.replace(/\D/g, '');
  if (cleaned.startsWith('91') && cleaned.length === 12) {
    return `+${cleaned}`;
  } else if (cleaned.length === 10) {
    return `+91${cleaned}`;
  }
  return mobile;
}

export function validateGSTIN(gstin: string): boolean {
  const gstinRegex = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;
  return gstinRegex.test(gstin);
}

export function validatePhoneNumber(phone: string): boolean {
  const phoneRegex = /^[6-9]\d{9}$/;
  return phoneRegex.test(phone);
}

export function sanitizeInput(input: string): string {
  return input.trim().replace(/[<>]/g, '');
}

export function validatePAN(pan: string): boolean {
  const panRegex = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
  return panRegex.test(pan);
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

export async function createJWT(payload: any, secret: string): Promise<string> {
  const header = { alg: 'HS256', typ: 'JWT' };
  const encodedHeader = btoa(JSON.stringify(header));
  const encodedPayload = btoa(JSON.stringify(payload));

  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  const signatureBuffer = await crypto.subtle.sign(
    'HMAC',
    key,
    encoder.encode(`${encodedHeader}.${encodedPayload}`)
  );
  const signature = btoa(String.fromCharCode(...new Uint8Array(signatureBuffer)));

  return `${encodedHeader}.${encodedPayload}.${signature}`;
}

export async function verifyJWT(token: string, secret: string): Promise<any> {
  try {
    const [encodedHeader, encodedPayload, signature] = token.split('.');

    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      'raw',
      encoder.encode(secret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['verify']
    );
    const signatureBuffer = Uint8Array.from(atob(signature), c => c.charCodeAt(0));
    const isValid = await crypto.subtle.verify(
      'HMAC',
      key,
      signatureBuffer,
      encoder.encode(`${encodedHeader}.${encodedPayload}`)
    );

    if (!isValid) {
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
