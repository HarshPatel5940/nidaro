# Nidaro
Nidaro is your shield against business fraud and bad debts.
Report scams. View proof. Stay alert.

✅ Search businesses by PAN, mobile, or name

📝 Submit verified public reports with evidence

👥 Community attests to confirm authenticity

🔒 Anonymous trails ensure safe, transparent reporting

> Truth deserves a platform. Nidaro is that platform.

🌐 Powered by the community. Protected by verification.

— Trust. Trace. Testify. That’s Nidaro.

## Core Features
1. Authentication (Phone + OTP via Twilio)
2. Report Management
3. Search Functionality
4. User Profiles
5. Verification System

## Tech Stack
- Frontend: Lynx.js
- Backend: Cloudflare Workers
- Database: Cloudflare D1 (SQL)
- Authentication: Twilio Verify API
- Storage: Cloudflare R2 (for proof attachments)

## Database Schema
```sql
-- Users table
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  phone_number TEXT UNIQUE NOT NULL,
  name TEXT,
  email TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Businesses table
CREATE TABLE businesses (
  id TEXT PRIMARY KEY,
  name TEXT,
  pan_number TEXT UNIQUE,
  phone_number TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reports table
CREATE TABLE reports (
  id TEXT PRIMARY KEY,
  reporter_id TEXT NOT NULL,
  business_id TEXT NOT NULL,
  description TEXT NOT NULL,
  amount REAL,
  proof_url TEXT,
  status TEXT DEFAULT 'pending', -- pending, verified, rejected
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (reporter_id) REFERENCES users(id),
  FOREIGN KEY (business_id) REFERENCES businesses(id)
);

-- Verifications table (for attestations)
CREATE TABLE verifications (
  id TEXT PRIMARY KEY,
  report_id TEXT NOT NULL,
  verifier_id TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (report_id) REFERENCES reports(id),
  FOREIGN KEY (verifier_id) REFERENCES users(id),
  UNIQUE(report_id, verifier_id)
);

-- Disputes table
CREATE TABLE disputes (
  id TEXT PRIMARY KEY,
  report_id TEXT NOT NULL,
  disputed_by TEXT NOT NULL,
  reason TEXT NOT NULL,
  status TEXT DEFAULT 'pending', -- pending, resolved
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (report_id) REFERENCES reports(id),
  FOREIGN KEY (disputed_by) REFERENCES users(id)
);
```

## API Endpoints
1. Authentication
   - POST /auth/send-otp
   - POST /auth/verify-otp

2. User Management
   - GET /users/profile
   - PUT /users/profile
   - GET /users/reports-against-me

3. Business Management
   - POST /businesses
   - GET /businesses/search
   - GET /businesses/:id

4. Report Management
   - POST /reports
   - GET /reports
   - GET /reports/:id
   - POST /reports/:id/verify
   - POST /reports/:id/dispute

5. File Management
   - POST /upload-proof