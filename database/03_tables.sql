-- 03_tables.sql
-- Core 18 Tables + 1 Audit Table for Aarogya Sathi.

DROP TABLE IF EXISTS corporate_employee_mapping CASCADE;
DROP TABLE IF EXISTS corporate_accounts CASCADE;
DROP TABLE IF EXISTS user_feedback CASCADE;
DROP TABLE IF EXISTS api_usage CASCADE;
DROP TABLE IF EXISTS user_analytics CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS abdm_integrations CASCADE;
DROP TABLE IF EXISTS auth_sessions CASCADE;
DROP TABLE IF EXISTS user_preferences CASCADE;
DROP TABLE IF EXISTS health_conditions CASCADE;
DROP TABLE IF EXISTS environmental_alerts CASCADE;
DROP TABLE IF EXISTS medical_reports CASCADE;
DROP TABLE IF EXISTS chat_history CASCADE;
DROP TABLE IF EXISTS health_records_audit CASCADE;
DROP TABLE IF EXISTS health_records CASCADE;
DROP TABLE IF EXISTS daily_steps CASCADE;
DROP TABLE IF EXISTS workouts CASCADE;
DROP TABLE IF EXISTS reminders CASCADE;
DROP TABLE IF EXISTS users CASCADE;


-- 1. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Authentication
    email email_domain UNIQUE NOT NULL,
    phone phone_domain UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    
    -- Profile
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender user_gender,
    height_cm DECIMAL(5, 2), -- Added as per review
    
    -- Preferences
    preferred_language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    preferred_city VARCHAR(100),
    
    -- Health ID (ABDM)
    abha_id VARCHAR(100) UNIQUE,
    abha_linked_at TIMESTAMP,
    
    -- Subscription
    subscription_plan subscription_plan_type DEFAULT 'free',
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

-- 2. Health Records Table
CREATE TABLE health_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Record Type
    record_type health_record_type NOT NULL,
    
    -- Symptom Data
    symptom_description TEXT,
    symptom_severity severity_domain,
    symptom_duration VARCHAR(100),
    symptom_triggers JSONB,
    
    -- Vital Signs
    blood_pressure_systolic bp_reading,
    blood_pressure_diastolic bp_reading,
    heart_rate INT CHECK (heart_rate > 0 AND heart_rate < 300),
    blood_sugar_fasting sugar_reading,
    blood_sugar_random sugar_reading,
    blood_sugar_pp sugar_reading,
    weight_kg DECIMAL(5, 2),
    height_cm DECIMAL(5, 2), -- User table also has height, this is for historical tracking
    temperature_celsius DECIMAL(4, 1),
    
    -- Other Metrics
    sleep_hours DECIMAL(3, 1),
    sleep_quality VARCHAR(50),
    stress_level severity_domain,
    activity_level VARCHAR(50),
    exercise_minutes INT,
    water_intake_liters DECIMAL(3, 1),
    alcohol_units INT,
    smoking_status VARCHAR(50),
    
    -- Contextual Data
    environmental_context JSONB,
    food_items TEXT[],
    medications_taken TEXT[],
    
    -- Location
    recorded_location_city VARCHAR(100),
    recorded_location_lat DECIMAL(10, 8),
    recorded_location_lon DECIMAL(11, 8),
    
    -- Timestamps
    recorded_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Metadata
    data_source VARCHAR(50),
    confidence_score DECIMAL(3, 2),
    notes TEXT
);

-- 3. Health Records Audit Table (The extra 1 table for auditing)
CREATE TABLE health_records_audit (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    record_id UUID NOT NULL,
    user_id UUID NOT NULL,
    action_type VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    old_data JSONB,
    new_data JSONB,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50) DEFAULT 'system'
);

-- 4. Chat History Table
CREATE TABLE chat_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Messages
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    
    -- Context at time of chat
    environmental_context JSONB,
    user_health_context JSONB,
    
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
    user_satisfaction_rating rating_domain,
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

-- 5. Medical Reports Table
CREATE TABLE medical_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    report_date DATE NOT NULL,
    report_type VARCHAR(100),
    test_name VARCHAR(255),
    lab_name VARCHAR(255),
    lab_location VARCHAR(255),
    
    biomarkers JSONB,
    
    extracted_text TEXT,
    interpretation TEXT,
    key_findings TEXT[],
    abnormal_values JSONB,
    health_risks JSONB,
    
    report_image_url VARCHAR(500),
    report_image_s3_key VARCHAR(500),
    raw_image_file_size INT,
    
    ocr_confidence_score DECIMAL(3, 2),
    biomarker_extraction_confidence JSONB,
    needs_manual_review BOOLEAN DEFAULT false,
    manual_review_by_user BOOLEAN DEFAULT false,
    
    is_encrypted BOOLEAN DEFAULT true,
    encryption_key_id VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    deleted_at TIMESTAMP
);

-- 6. Environmental Alerts Table
CREATE TABLE environmental_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    alert_type alert_type_enum NOT NULL,
    alert_severity alert_severity_level NOT NULL,
    
    alert_title VARCHAR(255),
    alert_description TEXT,
    alert_recommendation TEXT,
    
    location_city VARCHAR(100),
    location_lat DECIMAL(10, 8),
    location_lon DECIMAL(11, 8),
    aqi_value INT,
    aqi_level VARCHAR(50),
    temperature_celsius DECIMAL(4, 1),
    humidity_percent INT,
    wind_speed_kmh DECIMAL(4, 1),
    
    triggering_metric VARCHAR(100),
    triggering_value DECIMAL(10, 2),
    threshold_value DECIMAL(10, 2),
    
    health_conditions_affected TEXT[],
    recommended_actions TEXT[],
    
    was_dismissed BOOLEAN DEFAULT false,
    was_clicked BOOLEAN DEFAULT false,
    action_taken TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    sent_via_notification BOOLEAN DEFAULT true
);

-- 7. Health Conditions Tracking Table
CREATE TABLE health_conditions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    condition_name VARCHAR(255) NOT NULL,
    condition_category VARCHAR(100),
    condition_status condition_status_enum DEFAULT 'active',
    
    severity_level VARCHAR(50),
    diagnosis_date DATE,
    diagnosis_source VARCHAR(100),
    
    current_medications TEXT[],
    lifestyle_modifications TEXT[],
    dietary_restrictions TEXT[],
    activity_restrictions TEXT[],
    
    monitoring_frequency VARCHAR(100),
    target_metrics JSONB,
    
    treating_doctor_name VARCHAR(255),
    treating_doctor_hospital VARCHAR(255),
    last_consultation_date DATE,
    next_consultation_date DATE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- 8. User Preferences & Settings Table
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    notifications_enabled BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    push_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    
    alert_aqi_threshold INT DEFAULT 300,
    alert_temperature_high INT DEFAULT 40,
    alert_temperature_low INT DEFAULT 5,
    alert_frequency VARCHAR(50) DEFAULT 'daily',
    
    voice_input_enabled BOOLEAN DEFAULT true,
    voice_output_enabled BOOLEAN DEFAULT true,
    voice_language VARCHAR(10) DEFAULT 'hi',
    voice_gender user_gender,
    
    share_health_data_government BOOLEAN DEFAULT false,
    share_health_data_research BOOLEAN DEFAULT false,
    location_tracking_enabled BOOLEAN DEFAULT true,
    analytics_enabled BOOLEAN DEFAULT true,
    
    dark_mode BOOLEAN DEFAULT false,
    font_size VARCHAR(20) DEFAULT 'medium',
    units_system VARCHAR(20) DEFAULT 'metric',
    
    dietary_type VARCHAR(50),
    food_allergies TEXT[],
    preferred_cuisines TEXT[],
    
    preferred_exercise_type VARCHAR(100),
    target_daily_steps INT DEFAULT 10000,
    target_daily_exercise_minutes INT DEFAULT 30,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Authentication & Sessions Table
CREATE TABLE auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    access_token VARCHAR(500),
    refresh_token VARCHAR(500),
    token_type VARCHAR(50) DEFAULT 'Bearer',
    
    device_type VARCHAR(50),
    device_name VARCHAR(255),
    device_os VARCHAR(100),
    app_version VARCHAR(20),
    
    ip_address VARCHAR(50),
    user_agent TEXT,
    
    expires_at TIMESTAMP NOT NULL,
    refresh_token_expires_at TIMESTAMP,
    
    is_active BOOLEAN DEFAULT true,
    last_activity_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logged_out_at TIMESTAMP
);

-- 10. ABDM Integration Table
CREATE TABLE abdm_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    abha_number VARCHAR(100) UNIQUE NOT NULL,
    abha_address VARCHAR(255),
    
    consent_manager_id VARCHAR(100),
    health_facility_id VARCHAR(100),
    practitioner_id VARCHAR(100),
    
    access_token VARCHAR(500),
    refresh_token VARCHAR(500),
    token_expires_at TIMESTAMP,
    
    shared_records_count INT DEFAULT 0,
    last_record_shared_at TIMESTAMP,
    
    consent_given BOOLEAN DEFAULT false,
    consent_given_at TIMESTAMP,
    consent_expires_at TIMESTAMP,
    
    integration_status VARCHAR(50) DEFAULT 'linked',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. Subscriptions & Billing Table
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    plan_type subscription_plan_type NOT NULL,
    plan_name VARCHAR(255),
    plan_description TEXT,
    
    billing_amount_inr DECIMAL(10, 2),
    billing_cycle billing_cycle_type,
    billing_status VARCHAR(50) DEFAULT 'active',
    
    subscription_start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subscription_end_date TIMESTAMP,
    next_billing_date TIMESTAMP,
    renewal_date TIMESTAMP,
    
    auto_renewal BOOLEAN DEFAULT true,
    cancellation_date TIMESTAMP,
    cancellation_reason TEXT,
    
    features_included JSONB,
    
    payment_method VARCHAR(50),
    payment_gateway VARCHAR(100),
    payment_id VARCHAR(255),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Analytics & Usage Table
CREATE TABLE user_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    date DATE NOT NULL,
    UNIQUE(user_id, date), -- One entry per day per user
    
    total_messages_sent INT DEFAULT 0,
    total_voice_inputs INT DEFAULT 0,
    total_voice_outputs INT DEFAULT 0,
    total_reports_uploaded INT DEFAULT 0,
    total_health_records_logged INT DEFAULT 0,
    
    session_count INT DEFAULT 0,
    total_session_time_minutes INT DEFAULT 0,
    feature_usage JSONB,
    
    app_opened BOOLEAN DEFAULT false,
    is_active_user BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. API Usage & Rate Limiting Table
CREATE TABLE api_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    endpoint_path VARCHAR(255) NOT NULL,
    http_method VARCHAR(10),
    request_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    response_status_code INT,
    response_time_ms INT,
    
    model_used VARCHAR(100),
    input_tokens INT,
    output_tokens INT,
    total_tokens INT,
    estimated_cost_inr DECIMAL(10, 4),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 14. Feedback & Ratings Table
CREATE TABLE user_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    feedback_type VARCHAR(100),
    overall_rating rating_domain,
    feature_ratings JSONB,
    
    feedback_title VARCHAR(255),
    feedback_description TEXT,
    
    feature_used VARCHAR(255),
    context_data JSONB,
    attachments TEXT[],
    
    requires_response BOOLEAN DEFAULT false,
    response_text TEXT,
    responded_at TIMESTAMP,
    responded_by VARCHAR(255),
    
    status feedback_status DEFAULT 'open',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 15. Corporate Accounts Table
CREATE TABLE corporate_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    company_name VARCHAR(255) NOT NULL UNIQUE,
    company_registration_number VARCHAR(255) UNIQUE,
    industry VARCHAR(100),
    employee_count INT,
    location_city VARCHAR(100),
    location_state VARCHAR(100),
    
    primary_contact_name VARCHAR(255),
    primary_contact_email email_domain,
    primary_contact_phone phone_domain,
    
    contract_start_date DATE,
    contract_end_date DATE,
    contract_value_inr DECIMAL(15, 2),
    contract_frequency billing_cycle_type,
    
    subscription_status VARCHAR(50) DEFAULT 'active',
    assigned_employee_licenses INT,
    used_employee_licenses INT,
    
    features_included JSONB,
    api_key_primary VARCHAR(255),
    api_key_secondary VARCHAR(255),
    
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    suspended_at TIMESTAMP
);

-- 16. Corporate Employee Mapping Table
CREATE TABLE corporate_employee_mapping (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    corporate_account_id UUID NOT NULL REFERENCES corporate_accounts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(corporate_account_id, user_id),
    
    employee_id VARCHAR(100),
    employee_name VARCHAR(255),
    employee_email email_domain,
    department VARCHAR(100),
    designation VARCHAR(100),
    
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    enrollment_status VARCHAR(50) DEFAULT 'active',
    
    data_sharing_permission BOOLEAN DEFAULT false,
    aggregate_health_data_shareable BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 17. Fitness: Daily Steps Tracking Table
CREATE TABLE daily_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    log_date DATE NOT NULL,
    steps_count INT NOT NULL DEFAULT 0,
    distance_km DECIMAL(6, 2),
    calories_burned INT,
    active_minutes INT,
    
    data_source VARCHAR(50), -- 'device', 'manual', 'google_fit', 'apple_health'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, log_date)
);

-- 18. Fitness: Workouts Tracking Table
CREATE TABLE workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    workout_type VARCHAR(100) NOT NULL, -- 'running', 'yoga', 'strength_training', 'cycling', etc.
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    duration_minutes INT,
    
    intensity VARCHAR(50), -- 'low', 'moderate', 'high'
    calories_burned INT,
    avg_heart_rate INT,
    max_heart_rate INT,
    distance_km DECIMAL(6, 2),
    
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 19. Reminders Tracking Table
CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category reminder_category NOT NULL,
    
    reminder_time TIME NOT NULL,
    frequency VARCHAR(50) NOT NULL, -- 'daily', 'weekly', 'weekdays', 'custom'
    active_days INT[], -- [0, 1, 2, 3, 4, 5, 6] for Sunday to Saturday
    
    is_active BOOLEAN DEFAULT true,
    last_triggered_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
