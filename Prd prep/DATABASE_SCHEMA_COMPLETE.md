# AROGYA SATHI MVP - COMPLETE DATABASE SCHEMA & DESIGN
## Fresh Start: Everything From Scratch

**Version:** 2.0 - Fresh Design  
**Date:** January 7, 2026  
**Status:** Ready to implement  

---

## 1. DATABASE ARCHITECTURE OVERVIEW

### 1.1 Database Selection & Rationale

**Primary Database:** PostgreSQL
- **Why:** ACID compliance, JSON support, scalability, excellent for relational data
- **Version:** 15+
- **Character Set:** UTF-8 (supports Hindi, Marathi, English)

**Secondary Database:** SQLite (Local)
- **Why:** Offline functionality on mobile app
- **Purpose:** Local health data sync, chat history backup
- **Sync:** Automatic cloud sync when online

**Cache Layer:** Redis
- **Why:** Session management, rate limiting, API response caching
- **TTL:** 24 hours for health data, 1 hour for AQI data

---

## 2. COMPLETE DATABASE SCHEMA

### 2.1 Users Table

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Authentication
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    
    -- Profile
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20), -- 'male', 'female', 'other', 'prefer_not_to_say'
    
    -- Preferences
    preferred_language VARCHAR(10) DEFAULT 'en', -- 'en', 'hi', 'mr', 'ta', 'te', 'kn'
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    preferred_city VARCHAR(100),
    
    -- Health ID (ABDM)
    abha_id VARCHAR(100) UNIQUE,
    abha_linked_at TIMESTAMP,
    
    -- Subscription
    subscription_plan VARCHAR(50) DEFAULT 'free', -- 'free', 'premium', 'corporate'
    subscription_status VARCHAR(50) DEFAULT 'active',
    subscription_start_date TIMESTAMP,
    subscription_end_date TIMESTAMP,
    
    -- Privacy & Consent
    has_accepted_terms BOOLEAN DEFAULT false,
    terms_accepted_at TIMESTAMP,
    has_accepted_privacy BOOLEAN DEFAULT false,
    privacy_accepted_at TIMESTAMP,
    data_sharing_consent BOOLEAN DEFAULT false,
    research_consent BOOLEAN DEFAULT false,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    email_verified_at TIMESTAMP,
    phone_verified_at TIMESTAMP,
    
    -- Soft Delete
    deleted_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_abha_id ON users(abha_id);
CREATE INDEX idx_users_subscription_plan ON users(subscription_plan);
CREATE INDEX idx_users_created_at ON users(created_at);
```

### 2.2 Health Records Table

```sql
CREATE TABLE health_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Record Type
    record_type VARCHAR(50) NOT NULL, -- 'symptom', 'vitals', 'medical_report', 'medication', 'lifestyle'
    
    -- Symptom Data
    symptom_description TEXT,
    symptom_severity INT CHECK (symptom_severity >= 1 AND symptom_severity <= 10), -- 1-10 scale
    symptom_duration VARCHAR(100), -- 'days', 'weeks', 'months'
    symptom_triggers JSONB, -- {triggers: ['pollution', 'stress', 'food'], etc}
    
    -- Vital Signs
    blood_pressure_systolic INT,
    blood_pressure_diastolic INT,
    heart_rate INT,
    blood_sugar_fasting INT,
    blood_sugar_random INT,
    blood_sugar_pp INT, -- Post-prandial
    weight_kg DECIMAL(5, 2),
    height_cm DECIMAL(5, 2),
    temperature_celsius DECIMAL(4, 1),
    
    -- Other Metrics
    sleep_hours DECIMAL(3, 1),
    sleep_quality VARCHAR(50), -- 'poor', 'fair', 'good', 'excellent'
    stress_level INT CHECK (stress_level >= 1 AND stress_level <= 10),
    activity_level VARCHAR(50), -- 'sedentary', 'light', 'moderate', 'vigorous'
    exercise_minutes INT,
    water_intake_liters DECIMAL(3, 1),
    alcohol_units INT,
    smoking_status VARCHAR(50), -- 'never', 'former', 'current'
    
    -- Contextual Data
    environmental_context JSONB, -- {aqi: 350, temp: 42, humidity: 25, etc}
    food_items TEXT[], -- Array of food consumed
    medications_taken TEXT[], -- Array of medications
    
    -- Location
    recorded_location_city VARCHAR(100),
    recorded_location_lat DECIMAL(10, 8),
    recorded_location_lon DECIMAL(11, 8),
    
    -- Timestamps
    recorded_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Metadata
    data_source VARCHAR(50), -- 'manual', 'wearable', 'ocr', 'api'
    confidence_score DECIMAL(3, 2), -- For auto-extracted data
    notes TEXT
);

CREATE INDEX idx_health_records_user_id ON health_records(user_id);
CREATE INDEX idx_health_records_record_type ON health_records(record_type);
CREATE INDEX idx_health_records_recorded_at ON health_records(recorded_at);
CREATE INDEX idx_health_records_user_recorded ON health_records(user_id, recorded_at DESC);
```

### 2.3 Chat History Table

```sql
CREATE TABLE chat_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Messages
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    
    -- Context at time of chat
    environmental_context JSONB, -- {aqi, temp, humidity, etc}
    user_health_context JSONB, -- {recent_bp, recent_sugar, etc}
    
    -- AI Metadata
    model_used VARCHAR(50) DEFAULT 'gemini-2.0-flash',
    response_time_ms INT,
    tokens_used INT,
    temperature DECIMAL(2, 1),
    
    -- Message Metadata
    message_language VARCHAR(10),
    was_voice_input BOOLEAN DEFAULT false,
    was_voice_output BOOLEAN DEFAULT false,
    
    -- Feedback
    user_satisfaction_rating INT CHECK (user_satisfaction_rating >= 1 AND user_satisfaction_rating <= 5),
    is_medically_accurate BOOLEAN,
    feedback_text TEXT,
    
    -- Safety
    contained_emergency_keywords BOOLEAN DEFAULT false,
    contained_diagnosis_claim BOOLEAN DEFAULT false,
    contained_prescription BOOLEAN DEFAULT false,
    safety_check_passed BOOLEAN DEFAULT true,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_chat_history_user_id ON chat_history(user_id);
CREATE INDEX idx_chat_history_created_at ON chat_history(created_at);
CREATE INDEX idx_chat_history_user_created ON chat_history(user_id, created_at DESC);
CREATE INDEX idx_chat_history_safety ON chat_history(safety_check_passed);
```

### 2.4 Medical Reports Table

```sql
CREATE TABLE medical_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Report Metadata
    report_date DATE NOT NULL,
    report_type VARCHAR(100), -- 'blood_test', 'x_ray', 'ecg', 'ultrasound', etc
    test_name VARCHAR(255),
    lab_name VARCHAR(255),
    lab_location VARCHAR(255),
    
    -- Extracted Biomarkers (from OCR)
    biomarkers JSONB, -- {glucose: 125, HbA1c: 7.2, HDL: 50, etc}
    
    -- AI Analysis
    extracted_text TEXT, -- Full OCR text
    interpretation TEXT, -- AI interpretation
    key_findings TEXT[],
    abnormal_values JSONB,
    health_risks JSONB, -- {risk_type: 'diabetes', confidence: 0.85}
    
    -- Storage
    report_image_url VARCHAR(500),
    report_image_s3_key VARCHAR(500),
    raw_image_file_size INT,
    
    -- Processing
    ocr_confidence_score DECIMAL(3, 2),
    biomarker_extraction_confidence JSONB, -- {glucose: 0.95, HbA1c: 0.88}
    needs_manual_review BOOLEAN DEFAULT false,
    manual_review_by_user BOOLEAN DEFAULT false,
    
    -- Privacy
    is_encrypted BOOLEAN DEFAULT true,
    encryption_key_id VARCHAR(100),
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_medical_reports_user_id ON medical_reports(user_id);
CREATE INDEX idx_medical_reports_report_date ON medical_reports(report_date);
CREATE INDEX idx_medical_reports_needs_review ON medical_reports(needs_manual_review);
```

### 2.5 Environmental Alerts Table

```sql
CREATE TABLE environmental_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Alert Type
    alert_type VARCHAR(50) NOT NULL, -- 'aqi_spike', 'heatwave', 'cold_wave', 'monsoon', 'pollen'
    alert_severity VARCHAR(50) NOT NULL, -- 'low', 'moderate', 'high', 'critical'
    
    -- Alert Data
    alert_title VARCHAR(255),
    alert_description TEXT,
    alert_recommendation TEXT,
    
    -- Environmental Context
    location_city VARCHAR(100),
    location_lat DECIMAL(10, 8),
    location_lon DECIMAL(11, 8),
    aqi_value INT,
    aqi_level VARCHAR(50),
    temperature_celsius DECIMAL(4, 1),
    humidity_percent INT,
    wind_speed_kmh DECIMAL(4, 1),
    
    -- Trigger Thresholds
    triggering_metric VARCHAR(100), -- 'aqi', 'temp', 'humidity'
    triggering_value DECIMAL(10, 2),
    threshold_value DECIMAL(10, 2),
    
    -- Health Impact
    health_conditions_affected TEXT[], -- ['respiratory', 'cardiovascular']
    recommended_actions TEXT[],
    
    -- User Interaction
    was_dismissed BOOLEAN DEFAULT false,
    was_clicked BOOLEAN DEFAULT false,
    action_taken TEXT,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    sent_via_notification BOOLEAN DEFAULT true
);

CREATE INDEX idx_environmental_alerts_user_id ON environmental_alerts(user_id);
CREATE INDEX idx_environmental_alerts_severity ON environmental_alerts(alert_severity);
CREATE INDEX idx_environmental_alerts_created_at ON environmental_alerts(created_at DESC);
```

### 2.6 Health Conditions Tracking Table

```sql
CREATE TABLE health_conditions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Condition Info
    condition_name VARCHAR(255) NOT NULL, -- 'diabetes', 'hypertension', 'asthma'
    condition_category VARCHAR(100), -- 'chronic', 'acute', 'risk_factor'
    condition_status VARCHAR(50) DEFAULT 'active', -- 'active', 'controlled', 'managed', 'resolved'
    
    -- Medical Details
    severity_level VARCHAR(50), -- 'mild', 'moderate', 'severe'
    diagnosis_date DATE,
    diagnosis_source VARCHAR(100), -- 'self_reported', 'doctor_diagnosed', 'lab_confirmed'
    
    -- Management
    current_medications TEXT[],
    lifestyle_modifications TEXT[],
    dietary_restrictions TEXT[],
    activity_restrictions TEXT[],
    
    -- Monitoring
    monitoring_frequency VARCHAR(100), -- 'daily', 'weekly', 'monthly'
    target_metrics JSONB, -- {fasting_sugar: {min: 80, max: 130}, bp: {systolic: 140}}
    
    -- Doctor Information
    treating_doctor_name VARCHAR(255),
    treating_doctor_hospital VARCHAR(255),
    last_consultation_date DATE,
    next_consultation_date DATE,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

CREATE INDEX idx_health_conditions_user_id ON health_conditions(user_id);
CREATE INDEX idx_health_conditions_status ON health_conditions(condition_status);
```

### 2.7 User Preferences & Settings Table

```sql
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Notification Preferences
    notifications_enabled BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    push_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    
    -- Alert Settings
    alert_aqi_threshold INT DEFAULT 300,
    alert_temperature_high INT DEFAULT 40,
    alert_temperature_low INT DEFAULT 5,
    alert_frequency VARCHAR(50) DEFAULT 'daily', -- 'realtime', '6_hourly', 'daily', 'weekly'
    
    -- Voice Settings
    voice_input_enabled BOOLEAN DEFAULT true,
    voice_output_enabled BOOLEAN DEFAULT true,
    voice_language VARCHAR(10) DEFAULT 'hi',
    voice_gender VARCHAR(20), -- 'male', 'female'
    
    -- Privacy Settings
    share_health_data_government BOOLEAN DEFAULT false,
    share_health_data_research BOOLEAN DEFAULT false,
    location_tracking_enabled BOOLEAN DEFAULT true,
    analytics_enabled BOOLEAN DEFAULT true,
    
    -- Display Preferences
    dark_mode BOOLEAN DEFAULT false,
    font_size VARCHAR(20) DEFAULT 'medium',
    units_system VARCHAR(20) DEFAULT 'metric', -- 'metric', 'imperial'
    
    -- Dietary Preferences
    dietary_type VARCHAR(50), -- 'vegan', 'vegetarian', 'non_vegetarian'
    food_allergies TEXT[],
    preferred_cuisines TEXT[],
    
    -- Activity Preferences
    preferred_exercise_type VARCHAR(100), -- 'walking', 'yoga', 'gym', 'sports'
    target_daily_steps INT DEFAULT 10000,
    target_daily_exercise_minutes INT DEFAULT 30,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);
```

### 2.8 Authentication & Sessions Table

```sql
CREATE TABLE auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Token Info
    access_token VARCHAR(500),
    refresh_token VARCHAR(500),
    token_type VARCHAR(50) DEFAULT 'Bearer',
    
    -- Session Details
    device_type VARCHAR(50), -- 'android', 'ios', 'web'
    device_name VARCHAR(255),
    device_os VARCHAR(100),
    app_version VARCHAR(20),
    
    -- IP & Location
    ip_address VARCHAR(50),
    user_agent TEXT,
    
    -- Expiry
    expires_at TIMESTAMP NOT NULL,
    refresh_token_expires_at TIMESTAMP,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    last_activity_at TIMESTAMP,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logged_out_at TIMESTAMP
);

CREATE INDEX idx_auth_sessions_user_id ON auth_sessions(user_id);
CREATE INDEX idx_auth_sessions_expires_at ON auth_sessions(expires_at);
CREATE INDEX idx_auth_sessions_is_active ON auth_sessions(is_active);
```

### 2.9 ABDM Integration Table

```sql
CREATE TABLE abdm_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- ABHA Details
    abha_number VARCHAR(100) UNIQUE NOT NULL,
    abha_address VARCHAR(255),
    
    -- ABDM Integration
    consent_manager_id VARCHAR(100),
    health_facility_id VARCHAR(100),
    practitioner_id VARCHAR(100),
    
    -- Token Management
    access_token VARCHAR(500),
    refresh_token VARCHAR(500),
    token_expires_at TIMESTAMP,
    
    -- Shared Records
    shared_records_count INT DEFAULT 0,
    last_record_shared_at TIMESTAMP,
    
    -- Consent
    consent_given BOOLEAN DEFAULT false,
    consent_given_at TIMESTAMP,
    consent_expires_at TIMESTAMP,
    
    -- Status
    integration_status VARCHAR(50) DEFAULT 'linked', -- 'pending', 'linked', 'revoked'
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_abdm_integrations_user_id ON abdm_integrations(user_id);
CREATE INDEX idx_abdm_integrations_abha_number ON abdm_integrations(abha_number);
```

### 2.10 Subscriptions & Billing Table

```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Plan Details
    plan_type VARCHAR(50) NOT NULL, -- 'free', 'premium', 'corporate'
    plan_name VARCHAR(255),
    plan_description TEXT,
    
    -- Billing
    billing_amount_inr DECIMAL(10, 2),
    billing_cycle VARCHAR(50), -- 'monthly', 'yearly'
    billing_status VARCHAR(50) DEFAULT 'active', -- 'active', 'paused', 'cancelled'
    
    -- Dates
    subscription_start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subscription_end_date TIMESTAMP,
    next_billing_date TIMESTAMP,
    renewal_date TIMESTAMP,
    
    -- Auto Renewal
    auto_renewal BOOLEAN DEFAULT true,
    cancellation_date TIMESTAMP,
    cancellation_reason TEXT,
    
    -- Features
    features_included JSONB, -- {unlimited_chat: true, ocr: true, etc}
    
    -- Payment Method
    payment_method VARCHAR(50), -- 'credit_card', 'debit_card', 'upi', 'bank_transfer'
    payment_gateway VARCHAR(100), -- 'razorpay', 'stripe'
    payment_id VARCHAR(255),
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_plan_type ON subscriptions(plan_type);
CREATE INDEX idx_subscriptions_next_billing_date ON subscriptions(next_billing_date);
```

### 2.11 Analytics & Usage Table

```sql
CREATE TABLE user_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Daily Metrics
    date DATE NOT NULL,
    
    -- Usage Metrics
    total_messages_sent INT DEFAULT 0,
    total_voice_inputs INT DEFAULT 0,
    total_voice_outputs INT DEFAULT 0,
    total_reports_uploaded INT DEFAULT 0,
    total_health_records_logged INT DEFAULT 0,
    
    -- Engagement Metrics
    session_count INT DEFAULT 0,
    total_session_time_minutes INT DEFAULT 0,
    feature_usage JSONB, -- {chat: 10, health_tracking: 5, reports: 2}
    
    -- Retention
    app_opened BOOLEAN DEFAULT false,
    is_active_user BOOLEAN DEFAULT false,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_analytics_user_id ON user_analytics(user_id);
CREATE INDEX idx_user_analytics_date ON user_analytics(date);
CREATE INDEX idx_user_analytics_user_date ON user_analytics(user_id, date);
```

### 2.12 API Usage & Rate Limiting Table

```sql
CREATE TABLE api_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Request Details
    endpoint_path VARCHAR(255) NOT NULL,
    http_method VARCHAR(10),
    request_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Response Details
    response_status_code INT,
    response_time_ms INT,
    
    -- Gemini API Stats
    model_used VARCHAR(100),
    input_tokens INT,
    output_tokens INT,
    total_tokens INT,
    
    -- Cost Tracking
    estimated_cost_inr DECIMAL(10, 4),
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_api_usage_user_id ON api_usage(user_id);
CREATE INDEX idx_api_usage_endpoint ON api_usage(endpoint_path);
CREATE INDEX idx_api_usage_timestamp ON api_usage(request_timestamp);
```

### 2.13 Feedback & Ratings Table

```sql
CREATE TABLE user_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Feedback Type
    feedback_type VARCHAR(100), -- 'bug', 'feature_request', 'medical_accuracy', 'general'
    
    -- Rating
    overall_rating INT CHECK (overall_rating >= 1 AND overall_rating <= 5),
    feature_ratings JSONB, -- {chat: 4, health_tracking: 3, reports: 5}
    
    -- Content
    feedback_title VARCHAR(255),
    feedback_description TEXT,
    
    -- Metadata
    feature_used VARCHAR(255),
    context_data JSONB,
    attachments TEXT[], -- URLs to screenshots, etc
    
    -- Follow-up
    requires_response BOOLEAN DEFAULT false,
    response_text TEXT,
    responded_at TIMESTAMP,
    responded_by VARCHAR(255),
    
    -- Status
    status VARCHAR(50) DEFAULT 'open', -- 'open', 'in_progress', 'resolved', 'closed'
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_feedback_user_id ON user_feedback(user_id);
CREATE INDEX idx_user_feedback_type ON user_feedback(feedback_type);
CREATE INDEX idx_user_feedback_status ON user_feedback(status);
```

### 2.14 Corporate Accounts Table

```sql
CREATE TABLE corporate_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Company Details
    company_name VARCHAR(255) NOT NULL UNIQUE,
    company_registration_number VARCHAR(255) UNIQUE,
    industry VARCHAR(100),
    employee_count INT,
    location_city VARCHAR(100),
    location_state VARCHAR(100),
    
    -- Contact Information
    primary_contact_name VARCHAR(255),
    primary_contact_email VARCHAR(255),
    primary_contact_phone VARCHAR(20),
    
    -- Contract
    contract_start_date DATE,
    contract_end_date DATE,
    contract_value_inr DECIMAL(15, 2),
    contract_frequency VARCHAR(50), -- 'monthly', 'yearly'
    
    -- Subscription
    subscription_status VARCHAR(50) DEFAULT 'active',
    assigned_employee_licenses INT,
    used_employee_licenses INT,
    
    -- Features
    features_included JSONB, -- {unlimited_employees: true, custom_reports: true}
    
    -- API Access
    api_key_primary VARCHAR(255),
    api_key_secondary VARCHAR(255),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    suspended_at TIMESTAMP
);

CREATE INDEX idx_corporate_accounts_company_name ON corporate_accounts(company_name);
CREATE INDEX idx_corporate_accounts_subscription_status ON corporate_accounts(subscription_status);
```

### 2.15 Corporate Employee Mapping Table

```sql
CREATE TABLE corporate_employee_mapping (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    corporate_account_id UUID NOT NULL REFERENCES corporate_accounts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Employee Details (from corporate HR)
    employee_id VARCHAR(100),
    employee_name VARCHAR(255),
    employee_email VARCHAR(255),
    department VARCHAR(100),
    designation VARCHAR(100),
    
    -- Enrollment
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    enrollment_status VARCHAR(50) DEFAULT 'active', -- 'active', 'inactive', 'terminated'
    
    -- Data Sharing
    data_sharing_permission BOOLEAN DEFAULT false,
    aggregate_health_data_shareable BOOLEAN DEFAULT false,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_corporate_employee_mapping_corporate_id ON corporate_employee_mapping(corporate_account_id);
CREATE INDEX idx_corporate_employee_mapping_user_id ON corporate_employee_mapping(user_id);
```

---

## 3. DATABASE RELATIONSHIPS DIAGRAM

```
users (1) ──┬── (N) health_records
            ├── (N) chat_history
            ├── (N) medical_reports
            ├── (N) environmental_alerts
            ├── (N) health_conditions
            ├── (1) user_preferences
            ├── (N) auth_sessions
            ├── (1) abdm_integrations
            ├── (N) subscriptions
            ├── (N) user_analytics
            ├── (N) api_usage
            ├── (N) user_feedback
            └── (N) corporate_employee_mapping
            
corporate_accounts (1) ──── (N) corporate_employee_mapping
```

---

## 4. DATA TYPES & CONSTRAINTS

### 4.1 Custom Data Types (JSONB Examples)

```sql
-- Environmental Context JSONB Structure
{
  "city": "Delhi",
  "aqi": 350,
  "aqi_level": "Severe",
  "temperature": 42.5,
  "humidity": 25,
  "wind_speed": 2,
  "weather_condition": "Clear",
  "pollen_count": "High"
}

-- User Health Context JSONB
{
  "recent_bp": {
    "systolic": 140,
    "diastolic": 90,
    "measured_at": "2026-01-07T14:30:00Z"
  },
  "recent_sugar": {
    "fasting": 125,
    "random": 180,
    "measured_at": "2026-01-07T08:00:00Z"
  },
  "active_conditions": ["diabetes_type2", "hypertension"],
  "current_medications": ["metformin", "amlodipine"]
}

-- Biomarkers JSONB
{
  "glucose": 125,
  "HbA1c": 7.2,
  "total_cholesterol": 220,
  "HDL": 50,
  "LDL": 150,
  "triglycerides": 200,
  "creatinine": 0.9,
  "platelet_count": 200000
}
```

### 4.2 Enum Types

```sql
CREATE TYPE user_gender AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE subscription_plan_type AS ENUM ('free', 'premium', 'corporate');
CREATE TYPE health_record_type AS ENUM ('symptom', 'vitals', 'medical_report', 'medication', 'lifestyle');
CREATE TYPE alert_severity_level AS ENUM ('low', 'moderate', 'high', 'critical');
CREATE TYPE condition_status_enum AS ENUM ('active', 'controlled', 'managed', 'resolved');
```

---

## 5. DATABASE MIGRATIONS (Alembic)

### 5.1 Initial Migration File Structure

```
migrations/
├── versions/
│   ├── 001_create_users_table.py
│   ├── 002_create_health_records_table.py
│   ├── 003_create_chat_history_table.py
│   ├── 004_create_medical_reports_table.py
│   ├── 005_create_environmental_alerts_table.py
│   ├── 006_create_health_conditions_table.py
│   ├── 007_create_user_preferences_table.py
│   ├── 008_create_auth_sessions_table.py
│   ├── 009_create_abdm_integrations_table.py
│   ├── 010_create_subscriptions_table.py
│   ├── 011_create_user_analytics_table.py
│   ├── 012_create_api_usage_table.py
│   ├── 013_create_user_feedback_table.py
│   ├── 014_create_corporate_accounts_table.py
│   └── 015_create_corporate_employee_mapping_table.py
├── env.py
├── script.py.mako
└── README
```

### 5.2 Example Migration (001_create_users_table.py)

```python
"""Create users table"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID, JSON
import uuid

def upgrade():
    op.create_table(
        'users',
        sa.Column('id', UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('email', sa.String(255), unique=True, nullable=False),
        sa.Column('phone', sa.String(20), unique=True, nullable=False),
        sa.Column('password_hash', sa.String(255), nullable=False),
        sa.Column('first_name', sa.String(100), nullable=False),
        sa.Column('last_name', sa.String(100)),
        sa.Column('date_of_birth', sa.Date),
        sa.Column('gender', sa.String(20)),
        sa.Column('preferred_language', sa.String(10), server_default='en'),
        sa.Column('timezone', sa.String(50), server_default='Asia/Kolkata'),
        sa.Column('preferred_city', sa.String(100)),
        sa.Column('abha_id', sa.String(100), unique=True),
        sa.Column('abha_linked_at', sa.DateTime),
        sa.Column('subscription_plan', sa.String(50), server_default='free'),
        sa.Column('subscription_status', sa.String(50), server_default='active'),
        sa.Column('subscription_start_date', sa.DateTime),
        sa.Column('subscription_end_date', sa.DateTime),
        sa.Column('has_accepted_terms', sa.Boolean, server_default='false'),
        sa.Column('terms_accepted_at', sa.DateTime),
        sa.Column('has_accepted_privacy', sa.Boolean, server_default='false'),
        sa.Column('privacy_accepted_at', sa.DateTime),
        sa.Column('data_sharing_consent', sa.Boolean, server_default='false'),
        sa.Column('research_consent', sa.Boolean, server_default='false'),
        sa.Column('created_at', sa.DateTime, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime, server_default=sa.func.now()),
        sa.Column('last_login_at', sa.DateTime),
        sa.Column('is_active', sa.Boolean, server_default='true'),
        sa.Column('is_verified', sa.Boolean, server_default='false'),
        sa.Column('email_verified_at', sa.DateTime),
        sa.Column('phone_verified_at', sa.DateTime),
        sa.Column('deleted_at', sa.DateTime),
    )
    
    # Create indexes
    op.create_index('idx_users_email', 'users', ['email'])
    op.create_index('idx_users_phone', 'users', ['phone'])
    op.create_index('idx_users_abha_id', 'users', ['abha_id'])
    op.create_index('idx_users_subscription_plan', 'users', ['subscription_plan'])
    op.create_index('idx_users_created_at', 'users', ['created_at'])

def downgrade():
    op.drop_table('users')
```

---

## 6. VIEWS (For Common Queries)

```sql
-- User Health Summary View
CREATE VIEW user_health_summary AS
SELECT 
    u.id,
    u.first_name,
    u.email,
    COUNT(DISTINCT h.id) as total_health_records,
    MAX(h.recorded_at) as last_record_date,
    AVG(CASE WHEN h.record_type = 'vitals' THEN h.blood_pressure_systolic END) as avg_systolic_bp,
    AVG(CASE WHEN h.record_type = 'vitals' THEN h.blood_sugar_fasting END) as avg_fasting_sugar
FROM users u
LEFT JOIN health_records h ON u.id = h.user_id
GROUP BY u.id, u.first_name, u.email;

-- Active Users View (Last 30 Days)
CREATE VIEW active_users_30days AS
SELECT 
    u.id,
    u.first_name,
    u.email,
    COUNT(c.id) as messages_sent,
    MAX(c.created_at) as last_message_date
FROM users u
LEFT JOIN chat_history c ON u.id = c.user_id 
    AND c.created_at > NOW() - INTERVAL '30 days'
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.first_name, u.email
HAVING COUNT(c.id) > 0;

-- Corporate Dashboard View
CREATE VIEW corporate_dashboard_summary AS
SELECT 
    ca.id,
    ca.company_name,
    COUNT(DISTINCT cem.user_id) as enrolled_employees,
    COUNT(DISTINCT CASE WHEN cem.enrollment_status = 'active' THEN cem.user_id END) as active_employees,
    COUNT(DISTINCT h.id) as total_health_records,
    COUNT(DISTINCT c.id) as total_messages
FROM corporate_accounts ca
LEFT JOIN corporate_employee_mapping cem ON ca.id = cem.corporate_account_id
LEFT JOIN health_records h ON cem.user_id = h.user_id 
    AND h.created_at > NOW() - INTERVAL '30 days'
LEFT JOIN chat_history c ON cem.user_id = c.user_id 
    AND c.created_at > NOW() - INTERVAL '30 days'
WHERE ca.is_active = true
GROUP BY ca.id, ca.company_name;
```

---

## 7. TRIGGERS & FUNCTIONS

### 7.1 Auto-update Timestamp Trigger

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER health_records_updated_at BEFORE UPDATE ON health_records
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ... repeat for other tables
```

### 7.2 Subscription Expiry Check

```sql
CREATE OR REPLACE FUNCTION check_subscription_expiry()
RETURNS TABLE(user_id UUID, expired BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        CASE 
            WHEN s.subscription_end_date < NOW() THEN true
            ELSE false
        END as expired
    FROM users u
    LEFT JOIN subscriptions s ON u.id = s.user_id
    WHERE s.subscription_status = 'active';
END;
$$ LANGUAGE plpgsql;
```

---

## 8. PERFORMANCE OPTIMIZATION

### 8.1 Indexes Strategy

```sql
-- Composite Indexes (Most Important)
CREATE INDEX idx_health_records_user_recorded 
    ON health_records(user_id, recorded_at DESC);

CREATE INDEX idx_chat_history_user_created 
    ON chat_history(user_id, created_at DESC);

CREATE INDEX idx_user_analytics_user_date 
    ON user_analytics(user_id, date);

-- Partial Indexes (For Active Records)
CREATE INDEX idx_users_active 
    ON users(id) WHERE is_active = true;

CREATE INDEX idx_auth_sessions_active 
    ON auth_sessions(user_id) WHERE is_active = true;

-- Full Text Search Indexes (For Chat Queries)
CREATE INDEX idx_chat_history_message_search 
    ON chat_history USING GIN (to_tsvector('english', user_message));

-- JSONB Indexes
CREATE INDEX idx_health_records_biomarkers 
    ON medical_reports USING GIN (biomarkers);

CREATE INDEX idx_environmental_alerts_context 
    ON environmental_alerts USING GIN (environmental_context);
```

### 8.2 Query Optimization Tips

```sql
-- Use EXPLAIN ANALYZE to check query performance
EXPLAIN ANALYZE
SELECT * FROM users u
JOIN health_records h ON u.id = h.user_id
WHERE u.created_at > NOW() - INTERVAL '30 days'
ORDER BY h.recorded_at DESC;

-- Batch inserts instead of individual
INSERT INTO health_records (user_id, record_type, recorded_at)
VALUES 
    (user_id_1, 'symptom', NOW()),
    (user_id_2, 'vitals', NOW()),
    (user_id_3, 'medication', NOW());

-- Use pagination for large result sets
SELECT * FROM chat_history 
WHERE user_id = $1 
ORDER BY created_at DESC 
LIMIT 50 OFFSET 0;
```

---

## 9. BACKUP & RECOVERY

### 9.1 Backup Strategy

```bash
# Full backup
pg_dump arogya_sathi_mvp > backup_$(date +%Y%m%d_%H%M%S).sql

# Compressed backup
pg_dump -Z9 arogya_sathi_mvp > backup_$(date +%Y%m%d_%H%M%S).sql.gz

# Restore from backup
psql arogya_sathi_mvp < backup_20260107_123000.sql
```

### 9.2 High Availability (HA) Setup

```
Primary PostgreSQL (Production)
        ↓ (Streaming Replication)
Standby PostgreSQL (Backup)
        ↓ (Point-in-time Recovery)
Archive Storage (S3/Cloud)
```

---

## 10. SECURITY BEST PRACTICES

### 10.1 Column Encryption

```python
from cryptography.fernet import Fernet
import base64

class ColumnEncryption:
    def __init__(self, key):
        self.cipher = Fernet(key)
    
    def encrypt_column(self, value):
        return self.cipher.encrypt(value.encode()).decode()
    
    def decrypt_column(self, encrypted_value):
        return self.cipher.decrypt(encrypted_value.encode()).decode()

# Encrypt sensitive columns
encrypted_email = encrypt_column(user_email)
encrypted_phone = encrypt_column(user_phone)
encrypted_password = hash_password(user_password)  # Never encrypt, always hash
```

### 10.2 Row-Level Security (RLS)

```sql
-- Enable RLS on sensitive tables
ALTER TABLE health_records ENABLE ROW LEVEL SECURITY;

-- Users can only see their own health records
CREATE POLICY user_health_records_policy ON health_records
    FOR SELECT
    USING (user_id = current_user_id);

-- Only authenticated users
CREATE POLICY authenticated_users ON users
    FOR SELECT
    USING (auth.role() = 'authenticated');
```

---

**DATABASE SCHEMA COMPLETE & READY FOR IMPLEMENTATION**

**Status:** ✅ Production-Ready  
**Total Tables:** 15  
**Total Indexes:** 40+  
**Views:** 3  
**Triggers:** 5+  

