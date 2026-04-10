-- 02_types_and_domains.sql
-- Custom ENUM types and Domains for Aarogya Sathi Database

-- Drop existing types if they exist (useful for re-runs during development)
DROP TYPE IF EXISTS user_gender CASCADE;
DROP TYPE IF EXISTS subscription_plan_type CASCADE;
DROP TYPE IF EXISTS health_record_type CASCADE;
DROP TYPE IF EXISTS alert_type_enum CASCADE;
DROP TYPE IF EXISTS alert_severity_level CASCADE;
DROP TYPE IF EXISTS condition_status_enum CASCADE;
DROP TYPE IF EXISTS feedback_status CASCADE;
DROP TYPE IF EXISTS billing_cycle_type CASCADE;
DROP TYPE IF EXISTS reminder_category CASCADE;

DROP DOMAIN IF EXISTS email_domain CASCADE;
DROP DOMAIN IF EXISTS phone_domain CASCADE;
DROP DOMAIN IF EXISTS bp_reading CASCADE;
DROP DOMAIN IF EXISTS sugar_reading CASCADE;
DROP DOMAIN IF EXISTS rating_domain CASCADE;
DROP DOMAIN IF EXISTS severity_domain CASCADE;

-- 1. ENUMs
CREATE TYPE user_gender AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE subscription_plan_type AS ENUM ('free', 'premium', 'corporate');
CREATE TYPE health_record_type AS ENUM ('symptom', 'vitals', 'medical_report', 'medication', 'lifestyle');

-- 'health_emergency' added based on master review
CREATE TYPE alert_type_enum AS ENUM ('aqi_spike', 'heatwave', 'cold_wave', 'monsoon', 'pollen', 'health_threshold', 'health_emergency');
CREATE TYPE alert_severity_level AS ENUM ('low', 'moderate', 'high', 'critical');
CREATE TYPE condition_status_enum AS ENUM ('active', 'controlled', 'managed', 'resolved');
CREATE TYPE feedback_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');
CREATE TYPE billing_cycle_type AS ENUM ('monthly', 'yearly');

-- 'custom' added based on master review
CREATE TYPE reminder_category AS ENUM ('medication', 'water', 'meal', 'custom');

-- 2. DOMAINs
-- Simple regex for basic email validation
CREATE DOMAIN email_domain AS VARCHAR(255)
    CHECK (value ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$');

-- Validation for Indian phone numbers (+91...) or standard 10 digit, loose rule for leniency
CREATE DOMAIN phone_domain AS VARCHAR(20)
    CHECK (value ~ '^\+?[0-9]{10,15}$');

-- Systolic & Diastolic BP ranges
CREATE DOMAIN bp_reading AS INT
    CHECK (value >= 40 AND value <= 300);

-- Blood sugar readings (covering normal up to severe diabetic states)
CREATE DOMAIN sugar_reading AS INT
    CHECK (value >= 20 AND value <= 600);

-- 1 to 5 rating scale
CREATE DOMAIN rating_domain AS INT
    CHECK (value >= 1 AND value <= 5);

-- 1 to 10 severity scale
CREATE DOMAIN severity_domain AS INT
    CHECK (value >= 1 AND value <= 10);
