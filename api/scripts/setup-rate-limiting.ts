#!/usr/bin/env bun
/**
 * Cloudflare Rate Limiting Setup Script
 *
 * This script sets up rate limiting rules using Cloudflare's API
 * instead of implementing manual rate limiting in the application.
 *
 * Usage:
 * bun run scripts/setup-rate-limiting.ts
 */

import { readFileSync } from 'fs';
import { join } from 'path';

interface CloudflareRateLimit {
  id?: string;
  disabled?: boolean;
  description?: string;
  match?: {
    request?: {
      url?: string;
      methods?: string[];
    };
  };
  threshold?: number;
  period?: number;
  action?: {
    mode?: 'simulate' | 'ban' | 'challenge' | 'js_challenge' | 'managed_challenge';
    timeout?: number;
    response?: {
      content_type?: string;
      body?: string;
    };
  };
  correlate?: {
    by?: 'nat' | 'ip';
  };
}

interface CloudflareAPIResponse<T = any> {
  success: boolean;
  errors: Array<{
    code: number;
    message: string;
  }>;
  messages: string[];
  result: T;
  result_info?: {
    page: number;
    per_page: number;
    count: number;
    total_count: number;
  };
}

const CLOUDFLARE_CONFIG = {
  zoneId: process.env.CLOUDFLARE_ZONE_ID || '',
  apiToken: process.env.CLOUDFLARE_API_TOKEN || '',
  accountId: process.env.CLOUDFLARE_ACCOUNT_ID || '',
};

const RATE_LIMIT_RULES: CloudflareRateLimit[] = [
  {
    disabled: false,
    description: 'Global API rate limit - 100 requests per 15 minutes',
    match: {
      request: {
        url: '*nidaro.com/api/*',
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
      },
    },
    threshold: 100,
    period: 900,
    action: {
      mode: 'managed_challenge',
      timeout: 86400,
      response: {
        content_type: 'application/json',
        body: JSON.stringify({
          error: 'Too many requests. Please try again later.',
          code: 'RATE_LIMIT_EXCEEDED',
        }),
      },
    },
    correlate: {
      by: 'ip',
    },
  },

  {
    disabled: false,
    description: 'Auth endpoints rate limit - 10 requests per 5 minutes',
    match: {
      request: {
        url: '*nidaro.com/api/auth/*',
        methods: ['POST'],
      },
    },
    threshold: 10,
    period: 300,
    action: {
      mode: 'managed_challenge',
      timeout: 3600,
    },
    correlate: {
      by: 'ip',
    },
  },

  {
    disabled: false,
    description: 'OTP endpoints rate limit - 5 requests per 10 minutes',
    match: {
      request: {
        url: '*nidaro.com/api/auth/*/otp*',
        methods: ['POST'],
      },
    },
    threshold: 5,
    period: 600,
    action: {
      mode: 'ban',
      timeout: 7200,
    },
    correlate: {
      by: 'ip',
    },
  },

  {
    disabled: false,
    description: 'Business search rate limit - 50 requests per 10 minutes',
    match: {
      request: {
        url: '*nidaro.com/api/business*',
        methods: ['GET', 'POST'],
      },
    },
    threshold: 50,
    period: 600,
    action: {
      mode: 'js_challenge',
      timeout: 1800,
    },
    correlate: {
      by: 'ip',
    },
  },
];

async function makeCloudflareAPIRequest<T = any>(
  endpoint: string,
  method: string = 'GET',
  body?: any
): Promise<CloudflareAPIResponse<T>> {
  const url = `https://api.cloudflare.com/client/v4${endpoint}`;

  const response = await fetch(url, {
    method,
    headers: {
      Authorization: `Bearer ${CLOUDFLARE_CONFIG.apiToken}`,
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Cloudflare API error: ${response.status} ${error}`);
  }

  return response.json() as Promise<CloudflareAPIResponse<T>>;
}

async function createRateLimitRule(rule: CloudflareRateLimit) {
  console.log(`Creating rate limit rule: ${rule.description}`);

  try {
    const result = await makeCloudflareAPIRequest<CloudflareRateLimit>(
      `/zones/${CLOUDFLARE_CONFIG.zoneId}/rate_limits`,
      'POST',
      rule
    );

    if (result.success) {
      console.log(`✅ Created rule with ID: ${result.result.id}`);
      return result.result;
    } else {
      console.error(`❌ Failed to create rule:`, result.errors);
      return null;
    }
  } catch (error) {
    console.error(`❌ Error creating rule:`, error);
    return null;
  }
}

async function listExistingRules(): Promise<CloudflareRateLimit[]> {
  console.log('📋 Fetching existing rate limit rules...');

  try {
    const result = await makeCloudflareAPIRequest<CloudflareRateLimit[]>(
      `/zones/${CLOUDFLARE_CONFIG.zoneId}/rate_limits`
    );

    if (result.success) {
      console.log(`Found ${result.result.length} existing rules`);
      return result.result;
    } else {
      console.error('Failed to fetch existing rules:', result.errors);
      return [];
    }
  } catch (error) {
    console.error('Error fetching rules:', error);
    return [];
  }
}

async function deleteExistingRules() {
  const existingRules = await listExistingRules();

  for (const rule of existingRules) {
    console.log(`🗑️ Deleting existing rule: ${rule.description || rule.id}`);

    try {
      await makeCloudflareAPIRequest<void>(
        `/zones/${CLOUDFLARE_CONFIG.zoneId}/rate_limits/${rule.id}`,
        'DELETE'
      );
      console.log(`✅ Deleted rule: ${rule.id}`);
    } catch (error) {
      console.error(`❌ Error deleting rule ${rule.id}:`, error);
    }
  }
}

function loadConfigFromWrangler() {
  try {
    const wranglerPath = join(process.cwd(), 'wrangler.jsonc');
    const wranglerContent = readFileSync(wranglerPath, 'utf-8');

    const cleanJson = wranglerContent.replace(/\/\*[\s\S]*?\*\/|\/\/.*$/gm, '');
    const config = JSON.parse(cleanJson);

    if (config.env?.production?.zone_id) {
      CLOUDFLARE_CONFIG.zoneId = config.env.production.zone_id;
    }
    if (config.env?.production?.account_id) {
      CLOUDFLARE_CONFIG.accountId = config.env.production.account_id;
    }

    console.log('📄 Loaded configuration from wrangler.jsonc');
  } catch (error) {
    console.warn('⚠️ Could not load wrangler.jsonc, using environment variables');
  }
}

async function setupRateLimiting() {
  console.log('🚀 Setting up Cloudflare Rate Limiting...\n');

  loadConfigFromWrangler();

  if (!CLOUDFLARE_CONFIG.zoneId || !CLOUDFLARE_CONFIG.apiToken) {
    console.error('❌ Missing required Cloudflare configuration:');
    console.error('   - CLOUDFLARE_ZONE_ID');
    console.error('   - CLOUDFLARE_API_TOKEN');
    console.error('\nSet these as environment variables or in wrangler.jsonc');
    process.exit(1);
  }

  console.log(`🌍 Zone ID: ${CLOUDFLARE_CONFIG.zoneId}`);
  console.log(`🔑 API Token: ${CLOUDFLARE_CONFIG.apiToken.substring(0, 8)}...`);
  console.log('');

  const args = process.argv.slice(2);
  if (args.includes('--clean')) {
    await deleteExistingRules();
    console.log('');
  }

  console.log('📝 Creating rate limit rules...\n');

  for (const rule of RATE_LIMIT_RULES) {
    await createRateLimitRule(rule);
  }

  console.log('\n✨ Rate limiting setup complete!');
  console.log('\n📊 You can monitor rate limiting in the Cloudflare dashboard:');
  console.log(`   https://dash.cloudflare.com/${CLOUDFLARE_CONFIG.accountId}/analytics/security`);
}

if (import.meta.main) {
  setupRateLimiting().catch(error => {
    console.error('❌ Setup failed:', error);
    process.exit(1);
  });
}

export { setupRateLimiting, RATE_LIMIT_RULES, CLOUDFLARE_CONFIG };
