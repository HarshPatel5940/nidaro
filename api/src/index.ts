import { Hono } from 'hono';
import { corsMiddleware, securityHeadersMiddleware } from './middleware';
import type { Env, Variables } from './types';
import auth from './routes/auth';
import business from './routes/business';
import reports from './routes/reports';

const app = new Hono<{ Bindings: Env; Variables: Variables }>();

app.use('*', securityHeadersMiddleware);
app.use('*', corsMiddleware);

app.get('/', c => {
  return c.json({
    message: 'Nidaro API is running',
    version: '1.0.0',
    status: 'healthy',
  });
});

app.get('/api/status', c => {
  return c.json({
    api: 'Nidaro API',
    status: 'operational',
    endpoints: {
      auth: '/auth/* (includes login and signup)',
      business: '/business/*',
      reports: '/reports/*',
    },
  });
});

app.route('/auth', auth);
app.route('/business', business);
app.route('/reports', reports);

app.notFound(c => {
  return c.json({ error: 'Endpoint not found' }, 404);
});

app.onError((err, c) => {
  console.error('API Error:', err);
  return c.json({ error: 'Internal server error' }, 500);
});

export default app;
