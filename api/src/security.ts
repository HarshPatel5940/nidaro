export const SECURITY_CONFIG = {
  JWT: {
    EXPIRY_HOURS: 24 * 7,
    ALGORITHM: 'HS256',
  },

  PASSWORD: {
    MIN_LENGTH: 8,
    REQUIRE_UPPERCASE: true,
    REQUIRE_LOWERCASE: true,
    REQUIRE_NUMBERS: true,
    REQUIRE_SPECIAL_CHARS: true,
  },

  VALIDATION: {
    MAX_INPUT_LENGTH: 1000,
    ALLOWED_FILE_TYPES: ['image/jpeg', 'image/png', 'image/gif'] as string[],
    MAX_FILE_SIZE: 5 * 1024 * 1024,
  },

  CORS: {
    ALLOWED_ORIGINS: [
      'http://localhost:3000',
      'http://localhost:5173',
      'https://nidaro.com',
      'https://www.nidaro.com',
    ] as string[],
    ALLOWED_METHODS: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'] as string[],
    ALLOWED_HEADERS: ['Content-Type', 'Authorization', 'X-Requested-With'] as string[],
  },

  HEADERS: {
    CONTENT_SECURITY_POLICY:
      "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;",
    STRICT_TRANSPORT_SECURITY: 'max-age=31536000; includeSubDomains; preload',
    X_CONTENT_TYPE_OPTIONS: 'nosniff',
    X_FRAME_OPTIONS: 'DENY',
    X_XSS_PROTECTION: '1; mode=block',
    REFERRER_POLICY: 'strict-origin-when-cross-origin',
    PERMISSIONS_POLICY: 'geolocation=(), microphone=(), camera=()',
  },
} as const;

export function isSecurePassword(password: string): boolean {
  const { PASSWORD } = SECURITY_CONFIG;

  if (password.length < PASSWORD.MIN_LENGTH) return false;
  if (PASSWORD.REQUIRE_UPPERCASE && !/[A-Z]/.test(password)) return false;
  if (PASSWORD.REQUIRE_LOWERCASE && !/[a-z]/.test(password)) return false;
  if (PASSWORD.REQUIRE_NUMBERS && !/\d/.test(password)) return false;
  if (PASSWORD.REQUIRE_SPECIAL_CHARS && !/[!@#$%^&*(),.?":{}|<>]/.test(password)) return false;

  return true;
}

export function sanitizeAndValidateInput(input: string, maxLength?: number): string {
  const max = maxLength || SECURITY_CONFIG.VALIDATION.MAX_INPUT_LENGTH;

  const sanitized = input
    .trim()
    .replace(/[<>]/g, '')
    .replace(/javascript:/gi, '')
    .replace(/on\w+=/gi, '');

  if (sanitized.length > max) {
    throw new Error(`Input too long. Maximum ${max} characters allowed.`);
  }

  return sanitized;
}

export function validateFileUpload(file: File): boolean {
  const { VALIDATION } = SECURITY_CONFIG;

  if (!VALIDATION.ALLOWED_FILE_TYPES.includes(file.type)) {
    return false;
  }

  if (file.size > VALIDATION.MAX_FILE_SIZE) {
    return false;
  }

  return true;
}

export function logSecurityEvent(event: string, details: Record<string, any>) {
  console.warn(`[SECURITY] ${event}:`, {
    timestamp: new Date().toISOString(),
    ...details,
  });
}
