# Nidaro API

A Cloudflare Workers API built with Hono and powered by Bun for the Nidaro business fraud and debt reporting platform.

## Features

- 🔐 **Authentication**: Phone-based OTP authentication using Twilio
- 👥 **User Management**: Multi-step business verification process
- 📊 **GST Integration**: Real-time GST data fetching from government portals
- 📝 **Reporting System**: Community-driven business reporting and attestation
- 🔍 **Search**: Search businesses by PAN, mobile, or name
- ☁️ **Cloudflare Infrastructure**: D1 database, KV storage, and Workers

## Tech Stack

- **Runtime**: Cloudflare Workers
- **Framework**: Hono
- **Package Manager**: Bun
- **Database**: Cloudflare D1 (SQLite)
- **Storage**: Cloudflare KV
- **Secrets**: Cloudflare Workers Secrets
- **SMS**: Twilio Verify API
- **Language**: TypeScript

## Quick Start

### Prerequisites

- [Bun](https://bun.sh/) installed
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/install-and-update/) installed
- Cloudflare account
- Twilio account

### 1. Setup Development Environment

```bash
# Clone and navigate to the api directory
cd api

# Run the setup script (installs deps, creates DB, KV namespace)
bun run setup
```

### 2. Configure Cloudflare Resources

After running setup, update `wrangler.jsonc` with the generated IDs:

```jsonc
{
  "d1_databases": [
    {
      "binding": "DB",
      "database_name": "nidaro-db",
      "database_id": "your-generated-database-id"
    }
  ],
  "kv_namespaces": [
    {
      "binding": "NIDARO_KV",
      "id": "your-generated-kv-id",
      "preview_id": "your-generated-preview-kv-id"
    }
  ]
}
```

### 3. Set Up Secrets

```bash
# Set up Twilio secrets
wrangler secret put TWILIO_AUTH_TOKEN
# Enter your Twilio Auth Token when prompted

# Other secrets are set automatically by the setup script
```

### 4. Initialize Database

```bash
# Initialize the database schema
bun run db:init
```

### 5. Start Development Server

```bash
# Start the Cloudflare Workers development server
bun run dev
```

The API will be available at `http://localhost:8787`

## API Endpoints

### Public Routes

#### Authentication
- `POST /auth/login/mobile/otp` - Send OTP to mobile number
- `POST /auth/login/mobile/verify` - Verify OTP and get auth cookie

#### Signup Flow
- `POST /signup/step/1` - Initial signup (business name, mobile, password)
- `POST /signup/step/1/verify` - Verify mobile OTP for step 1
- `POST /signup/step/2` - Submit PAN verification details
- `POST /signup/step/2/verify` - Verify PAN details
- `POST /signup/step/3` - Get GSTIN from PAN
- `POST /signup/step/4` - Get GSTIN captcha and taxpayer details
- `POST /signup/step/5` - Complete GST verification

### Protected Routes (require auth cookie)

#### Business Management
- `GET /business` - Search businesses by type and value
- `PATCH /business/refetch` - Refetch business GST details

#### Reports Management
- `GET /reports` - Get user's reports
- `POST /reports` - Create a new report
- `GET /reports/:id` - Get specific report details
- `POST /reports/:id/attest` - Attest to a report

## Development Scripts

```bash
# Development
bun run dev              # Start Cloudflare Workers dev server
bun run dev:local        # Start local Bun server with watch mode

# Database
bun run db:init          # Initialize database schema (local)
bun run db:init-remote   # Initialize database schema (remote)
bun run db:create        # Create new D1 database

# Secrets & Configuration
bun run secrets:put      # Set up Cloudflare secrets
bun run kv:create        # Create KV namespace
bun run cf-typegen       # Generate Cloudflare types

# Code Quality
bun run typecheck        # TypeScript type checking
bun run format           # Format code with Prettier
bun run lint            # Lint code with ESLint

# Deployment
bun run deploy          # Deploy to Cloudflare Workers
```

## Project Structure

```
src/
├── index.ts              # Main application entry point
├── types.ts              # TypeScript type definitions
├── utils.ts              # Utility functions
├── middleware.ts         # Hono middleware
├── db/
│   └── schema.sql        # Database schema
├── routes/
│   ├── auth.ts           # Authentication routes
│   ├── signup.ts         # Signup flow routes
│   ├── business.ts       # Business management routes
│   └── reports.ts        # Reports and attestation routes
└── services/
    ├── twilio.ts         # Twilio integration
    └── gst.ts            # GST portal integration
```

## Environment Variables

Configure these in Cloudflare Workers secrets:

- `TWILIO_ACCOUNT_SID` - Your Twilio Account SID
- `TWILIO_AUTH_TOKEN` - Your Twilio Auth Token
- `TWILIO_VERIFY_SERVICE_SID` - Your Twilio Verify Service SID
- `JWT_SECRET` - Secret for JWT token signing

## Database Schema

The API uses Cloudflare D1 with the following main tables:
- `users` - User accounts and verification status
- `business_details` - GST and business information
- `reports` - User-submitted business reports
- `attestations` - Community attestations on reports
- `otp_sessions` - Temporary OTP verification sessions
- `captcha_sessions` - GST portal captcha sessions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `bun run typecheck` and `bun run format`
5. Submit a pull request

## License

MIT License - see LICENSE file for details
