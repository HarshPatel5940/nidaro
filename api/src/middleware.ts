import type { Context, Next } from 'hono';
import type { Env, Variables, AppContext } from './types';
import { getCookie, verifyJWT } from './utils';
import { SECURITY_CONFIG, logSecurityEvent } from './security';

export async function authMiddleware(c: AppContext, next: Next) {
  const token = getCookie(c, 'auth_token');

  if (!token) {
    return c.json({ error: 'Authentication required' }, 401);
  }

  try {
    const payload = (await verifyJWT(token, c.env.JWT_SECRET)) as {
      userId: string;
      businessName: string;
      mobileNo: string;
      isVerified: boolean;
    };
    c.set('user', payload);
    await next();
  } catch (error) {
    return c.json({ error: 'Invalid token' }, 401);
  }
}

export async function corsMiddleware(c: Context, next: Next) {
  const allowedOrigins = SECURITY_CONFIG.CORS.ALLOWED_ORIGINS;
  const origin = c.req.header('Origin');

  if (origin && allowedOrigins.includes(origin)) {
    c.header('Access-Control-Allow-Origin', origin);
    c.header('Access-Control-Allow-Credentials', 'true');
  } else {
    c.header('Access-Control-Allow-Origin', 'null');
    if (origin) {
      logSecurityEvent('CORS_VIOLATION', { origin, userAgent: c.req.header('User-Agent') });
    }
  }

  c.header('Access-Control-Allow-Methods', SECURITY_CONFIG.CORS.ALLOWED_METHODS.join(', '));
  c.header('Access-Control-Allow-Headers', SECURITY_CONFIG.CORS.ALLOWED_HEADERS.join(', '));

  if (c.req.method === 'OPTIONS') {
    return c.text('', 200);
  }

  await next();
}

export async function securityHeadersMiddleware(c: Context, next: Next) {
  const { HEADERS } = SECURITY_CONFIG;

  c.header('X-Content-Type-Options', HEADERS.X_CONTENT_TYPE_OPTIONS);
  c.header('X-Frame-Options', HEADERS.X_FRAME_OPTIONS);
  c.header('X-XSS-Protection', HEADERS.X_XSS_PROTECTION);
  c.header('Strict-Transport-Security', HEADERS.STRICT_TRANSPORT_SECURITY);
  c.header('Content-Security-Policy', HEADERS.CONTENT_SECURITY_POLICY);
  c.header('Referrer-Policy', HEADERS.REFERRER_POLICY);
  c.header('Permissions-Policy', HEADERS.PERMISSIONS_POLICY);

  await next();
}
