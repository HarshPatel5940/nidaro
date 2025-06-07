-- Users table
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    business_name TEXT NOT NULL,
    mobile_no TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    verification_phase INTEGER DEFAULT 1,
    is_verified BOOLEAN DEFAULT FALSE,
    user_pan TEXT,
    user_pan_name TEXT,
    user_dob TEXT,
    user_pan_mobile TEXT,
    gstin TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Business details table (stores GST data)
CREATE TABLE business_details (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    gstin TEXT UNIQUE NOT NULL,
    legal_name TEXT,
    trade_name TEXT,
    status TEXT,
    constitution TEXT,
    registration_date TEXT,
    address TEXT,
    nature_of_business TEXT,
    goods_services_json TEXT, -- JSON string
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Reports table
CREATE TABLE reports (
    id TEXT PRIMARY KEY,
    reporter_id TEXT NOT NULL,
    reported_business_gstin TEXT NOT NULL,
    report_type TEXT NOT NULL, -- 'money' or 'non_money'
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    evidence_json TEXT, -- JSON string for evidence URLs/data
    status TEXT DEFAULT 'pending', -- 'pending', 'verified', 'disputed'
    attestations_count INTEGER DEFAULT 0,
    min_attestations_required INTEGER DEFAULT 5,
    has_gov_dispute BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reporter_id) REFERENCES users(id)
);

-- Attestations table
CREATE TABLE attestations (
    id TEXT PRIMARY KEY,
    report_id TEXT NOT NULL,
    attester_id TEXT NOT NULL,
    is_supporting BOOLEAN NOT NULL, -- TRUE for support, FALSE for dispute
    comments TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (report_id) REFERENCES reports(id),
    FOREIGN KEY (attester_id) REFERENCES users(id),
    UNIQUE(report_id, attester_id)
);

-- OTP sessions table (for temporary storage)
CREATE TABLE otp_sessions (
    id TEXT PRIMARY KEY,
    mobile_no TEXT NOT NULL,
    otp_code TEXT NOT NULL,
    purpose TEXT NOT NULL, -- 'login', 'signup_step1', 'signup_step2'
    expires_at DATETIME NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Captcha sessions table
CREATE TABLE captcha_sessions (
    id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    captcha_image_base64 TEXT NOT NULL,
    purpose TEXT NOT NULL, -- 'pan_to_gst', 'gst_to_details'
    context_data TEXT, -- JSON string for storing context
    expires_at DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Index for better performance
CREATE INDEX idx_users_mobile ON users(mobile_no);
CREATE INDEX idx_business_gstin ON business_details(gstin);
CREATE INDEX idx_reports_business ON reports(reported_business_gstin);
CREATE INDEX idx_reports_reporter ON reports(reporter_id);
CREATE INDEX idx_attestations_report ON attestations(report_id);
CREATE INDEX idx_otp_mobile ON otp_sessions(mobile_no);
CREATE INDEX idx_captcha_session ON captcha_sessions(session_id);
