import type { Context, Next } from 'hono';
import type { Env, Variables, AppContext } from './types';
import { getCookie, verifyJWT } from './utils';

export async function authMiddleware(c: AppContext, next: Next) {
  const token = getCookie(c, 'auth_token');

  if (!token) {
    return c.json({ error: 'Authentication required' }, 401);
  }

  try {
    const payload = verifyJWT(token, c.env.JWT_SECRET) as {
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
  c.header('Access-Control-Allow-Origin', '*');
  c.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  c.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  c.header('Access-Control-Allow-Credentials', 'true');

  if (c.req.method === 'OPTIONS') {
    return c.text('', 200);
  }

  await next();
}
