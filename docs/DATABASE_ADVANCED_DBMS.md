# AAROGYA SATHI — Advanced DBMS Document
## ER, EER, Relational Schema, PL/SQL, Triggers & Advanced Features

**Version:** 3.0 | **Date:** March 10, 2026 | **Database:** PostgreSQL 15+

---

## Table of Contents

1. [ER Diagram](#1-er-diagram)
2. [Enhanced ER (EER) Diagram](#2-enhanced-er-eer-diagram)
3. [Relational Schema & Normalization](#3-relational-schema--normalization)
4. [Custom Types & Domains](#4-custom-types--domains)
5. [Stored Procedures](#5-stored-procedures)
6. [Functions](#6-functions)
7. [PL/SQL Packages](#7-plsql-packages)
8. [Triggers](#8-triggers)
9. [Cursors](#9-cursors)
10. [Views & Materialized Views](#10-views--materialized-views)
11. [Advanced Indexing](#11-advanced-indexing)
12. [Partitioning Strategy](#12-partitioning-strategy)
13. [CTEs & Window Functions](#13-ctes--window-functions)
14. [Transaction Management](#14-transaction-management)
15. [Row-Level Security](#15-row-level-security)

---

## 1. ER Diagram

### 1.1 Entity-Relationship Diagram (15 Entities)

```mermaid
erDiagram
    USERS ||--o{ HEALTH_RECORDS : "logs"
    USERS ||--o{ CHAT_HISTORY : "sends"
    USERS ||--o{ MEDICAL_REPORTS : "uploads"
    USERS ||--o{ ENVIRONMENTAL_ALERTS : "receives"
    USERS ||--o{ HEALTH_CONDITIONS : "has"
    USERS ||--|| USER_PREFERENCES : "configures"
    USERS ||--o{ AUTH_SESSIONS : "authenticates"
    USERS ||--o| ABDM_INTEGRATIONS : "links"
    USERS ||--o{ SUBSCRIPTIONS : "subscribes"
    USERS ||--o{ USER_ANALYTICS : "generates"
    USERS ||--o{ API_USAGE : "consumes"
    USERS ||--o{ USER_FEEDBACK : "submits"
    USERS ||--o{ CORPORATE_EMPLOYEE_MAPPING : "enrolled_in"
    CORPORATE_ACCOUNTS ||--o{ CORPORATE_EMPLOYEE_MAPPING : "manages"

    USERS {
        UUID id PK
        VARCHAR email UK
        VARCHAR phone UK
        VARCHAR password_hash
        VARCHAR first_name
        VARCHAR preferred_language
        VARCHAR preferred_city
        VARCHAR subscription_plan
        BOOLEAN is_active
        TIMESTAMP created_at
    }

    HEALTH_RECORDS {
        UUID id PK
        UUID user_id FK
        VARCHAR record_type
        INT bp_systolic
        INT bp_diastolic
        INT blood_sugar_fasting
        DECIMAL weight_kg
        JSONB environmental_context
        TIMESTAMP recorded_at
    }

    CHAT_HISTORY {
        UUID id PK
        UUID user_id FK
        TEXT user_message
        TEXT ai_response
        VARCHAR model_used
        INT tokens_used
        BOOLEAN safety_check_passed
        TIMESTAMP created_at
    }

    MEDICAL_REPORTS {
        UUID id PK
        UUID user_id FK
        DATE report_date
        VARCHAR report_type
        JSONB biomarkers
        TEXT interpretation
        JSONB abnormal_values
        DECIMAL ocr_confidence
    }

    ENVIRONMENTAL_ALERTS {
        UUID id PK
        UUID user_id FK
        VARCHAR alert_type
        VARCHAR alert_severity
        INT aqi_value
        DECIMAL temperature
        TEXT alert_recommendation
    }

    HEALTH_CONDITIONS {
        UUID id PK
        UUID user_id FK
        VARCHAR condition_name
        VARCHAR condition_status
        VARCHAR severity_level
        JSONB target_metrics
    }

    USER_PREFERENCES {
        UUID id PK
        UUID user_id FK
        BOOLEAN notifications_enabled
        INT alert_aqi_threshold
        BOOLEAN voice_input_enabled
        VARCHAR voice_language
        BOOLEAN dark_mode
    }

    AUTH_SESSIONS {
        UUID id PK
        UUID user_id FK
        VARCHAR access_token
        VARCHAR refresh_token
        VARCHAR device_type
        TIMESTAMP expires_at
        BOOLEAN is_active
    }

    ABDM_INTEGRATIONS {
        UUID id PK
        UUID user_id FK
        VARCHAR abha_number UK
        BOOLEAN consent_given
        VARCHAR integration_status
    }

    SUBSCRIPTIONS {
        UUID id PK
        UUID user_id FK
        VARCHAR plan_type
        DECIMAL billing_amount_inr
        VARCHAR billing_cycle
        TIMESTAMP subscription_end_date
        BOOLEAN auto_renewal
    }

    USER_ANALYTICS {
        UUID id PK
        UUID user_id FK
        DATE date
        INT total_messages_sent
        INT session_count
        JSONB feature_usage
    }

    API_USAGE {
        UUID id PK
        UUID user_id FK
        VARCHAR endpoint_path
        INT input_tokens
        INT output_tokens
        DECIMAL estimated_cost_inr
    }

    USER_FEEDBACK {
        UUID id PK
        UUID user_id FK
        VARCHAR feedback_type
        INT overall_rating
        TEXT feedback_description
        VARCHAR status
    }

    CORPORATE_ACCOUNTS {
        UUID id PK
        VARCHAR company_name UK
        INT employee_count
        DECIMAL contract_value_inr
        INT assigned_employee_licenses
        BOOLEAN is_active
    }

    CORPORATE_EMPLOYEE_MAPPING {
        UUID id PK
        UUID corporate_account_id FK
        UUID user_id FK
        VARCHAR employee_id
        VARCHAR department
        BOOLEAN data_sharing_permission
    }
```

### 1.2 Cardinality Summary

| Relationship | Type | Description |
|-------------|------|-------------|
| USERS → HEALTH_RECORDS | 1:N | A user logs many health records |
| USERS → CHAT_HISTORY | 1:N | A user sends many messages |
| USERS → MEDICAL_REPORTS | 1:N | A user uploads many reports |
| USERS → ENVIRONMENTAL_ALERTS | 1:N | A user receives many alerts |
| USERS → HEALTH_CONDITIONS | 1:N | A user can have many conditions |
| USERS → USER_PREFERENCES | 1:1 | Each user has exactly one preferences record |
| USERS → AUTH_SESSIONS | 1:N | A user can have many active sessions |
| USERS → ABDM_INTEGRATIONS | 1:0..1 | A user may or may not link ABHA |
| USERS → SUBSCRIPTIONS | 1:N | A user can have subscription history |
| USERS → CORPORATE_EMPLOYEE_MAPPING | 1:0..N | A user may be enrolled in 0+ corporate accounts |
| CORPORATE_ACCOUNTS → CORPORATE_EMPLOYEE_MAPPING | 1:N | A company manages many employee links |

---

## 2. Enhanced ER (EER) Diagram

### 2.1 Specialization / Generalization

```mermaid
graph TB
    HR[HEALTH_RECORDS<br/>Superclass] --> V[VITALS<br/>bp_systolic, bp_diastolic,<br/>heart_rate, blood_sugar]
    HR --> S[SYMPTOMS<br/>symptom_description,<br/>severity, duration, triggers]
    HR --> L[LIFESTYLE<br/>sleep_hours, exercise_mins,<br/>water_intake, stress_level]
    HR --> M[MEDICATION<br/>medications_taken,<br/>adherence_status]

    style HR fill:#4CAF50,color:white
    style V fill:#2196F3,color:white
    style S fill:#FF9800,color:white
    style L fill:#9C27B0,color:white
    style M fill:#F44336,color:white
```

**Mapping:** Implemented via `record_type` discriminator column in `health_records` table (single-table inheritance):
- `record_type = 'vitals'` → uses BP, sugar, heart_rate columns
- `record_type = 'symptom'` → uses symptom_description, severity columns
- `record_type = 'lifestyle'` → uses sleep, exercise, water columns
- `record_type = 'medication'` → uses medications_taken array

### 2.2 Aggregation

```
USERS ──── participates_in ──── CORPORATE_EMPLOYEE_MAPPING
                                        │
                                  aggregation of
                                        │
                               CORPORATE_ACCOUNTS
```

The `corporate_employee_mapping` table is an aggregation entity that links users to corporate accounts with additional attributes (employee_id, department, data_sharing_permission).

---

## 3. Relational Schema & Normalization

### 3.1 Normalization Proof

**1NF (First Normal Form):**
- All tables have atomic values per cell ✅
- Each table has a primary key (UUID) ✅
- JSONB columns store structured data but each JSONB field is a single atomic unit ✅

**2NF (Second Normal Form):**
- All non-key attributes are fully dependent on the entire primary key ✅
- No partial dependencies exist (all PKs are single-column UUIDs) ✅

**3NF (Third Normal Form):**
- No transitive dependencies ✅
- Example validation: In `users`, `subscription_plan` determines subscription features, but features are stored in `subscriptions.features_included` (separate table), not in `users` ✅

**BCNF (Boyce-Codd Normal Form):**
- Every determinant is a candidate key ✅
- `users.email` and `users.phone` are both candidate keys (UNIQUE constraints) ✅

### 3.2 Functional Dependencies (Selected Tables)

**users:**
```
id → {email, phone, password_hash, first_name, last_name, preferred_language, ...}
email → {id}  (candidate key)
phone → {id}  (candidate key)
```

**health_records:**
```
id → {user_id, record_type, bp_systolic, bp_diastolic, ..., recorded_at}
```

**chat_history:**
```
id → {user_id, user_message, ai_response, model_used, tokens_used, ...}
```

---

## 4. Custom Types & Domains

```sql
-- Enum Types
CREATE TYPE user_gender AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE subscription_plan_type AS ENUM ('free', 'premium', 'corporate');
CREATE TYPE health_record_type AS ENUM ('symptom', 'vitals', 'medical_report', 'medication', 'lifestyle');
CREATE TYPE alert_severity_level AS ENUM ('low', 'moderate', 'high', 'critical');
CREATE TYPE condition_status_enum AS ENUM ('active', 'controlled', 'managed', 'resolved');
CREATE TYPE feedback_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');
CREATE TYPE billing_cycle_type AS ENUM ('monthly', 'yearly');

-- Domains with constraints
CREATE DOMAIN email_domain AS VARCHAR(255)
    CHECK (VALUE ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

CREATE DOMAIN phone_domain AS VARCHAR(20)
    CHECK (VALUE ~* '^\+?[0-9]{10,15}$');

CREATE DOMAIN bp_reading AS INT
    CHECK (VALUE >= 40 AND VALUE <= 300);

CREATE DOMAIN sugar_reading AS INT
    CHECK (VALUE >= 20 AND VALUE <= 600);

CREATE DOMAIN rating_domain AS INT
    CHECK (VALUE >= 1 AND VALUE <= 5);

CREATE DOMAIN severity_domain AS INT
    CHECK (VALUE >= 1 AND VALUE <= 10);
```

---

## 5. Stored Procedures

### 5.1 Create User with Preferences

```sql
CREATE OR REPLACE PROCEDURE sp_create_user(
    p_email VARCHAR,
    p_phone VARCHAR,
    p_password_hash VARCHAR,
    p_first_name VARCHAR,
    p_last_name VARCHAR DEFAULT NULL,
    p_language VARCHAR DEFAULT 'en',
    p_city VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Insert user
    INSERT INTO users (email, phone, password_hash, first_name, last_name,
                       preferred_language, preferred_city, has_accepted_terms,
                       terms_accepted_at)
    VALUES (p_email, p_phone, p_password_hash, p_first_name, p_last_name,
            p_language, p_city, true, CURRENT_TIMESTAMP)
    RETURNING id INTO v_user_id;

    -- Auto-create preferences record
    INSERT INTO user_preferences (user_id, voice_language)
    VALUES (v_user_id, p_language);

    -- Auto-create free subscription
    INSERT INTO subscriptions (user_id, plan_type, plan_name, billing_amount_inr,
                               billing_cycle, billing_status)
    VALUES (v_user_id, 'free', 'Free Tier', 0, 'monthly', 'active');

    -- Initialize analytics for today
    INSERT INTO user_analytics (user_id, date, app_opened, is_active_user)
    VALUES (v_user_id, CURRENT_DATE, true, true);

    RAISE NOTICE 'User created: % (ID: %)', p_email, v_user_id;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Email or phone already registered: %', p_email;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'User creation failed: %', SQLERRM;
END;
$$;
```

### 5.2 Log Health Record with Alert Check

```sql
CREATE OR REPLACE PROCEDURE sp_log_health_record(
    p_user_id UUID,
    p_record_type VARCHAR,
    p_bp_systolic INT DEFAULT NULL,
    p_bp_diastolic INT DEFAULT NULL,
    p_sugar_fasting INT DEFAULT NULL,
    p_sugar_random INT DEFAULT NULL,
    p_city VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_record_id UUID;
    v_alert_needed BOOLEAN := false;
    v_alert_message TEXT;
BEGIN
    -- Insert health record
    INSERT INTO health_records (user_id, record_type, blood_pressure_systolic,
                                blood_pressure_diastolic, blood_sugar_fasting,
                                blood_sugar_random, recorded_location_city,
                                recorded_at, data_source)
    VALUES (p_user_id, p_record_type, p_bp_systolic, p_bp_diastolic,
            p_sugar_fasting, p_sugar_random, p_city, CURRENT_TIMESTAMP, 'manual')
    RETURNING id INTO v_record_id;

    -- Check BP thresholds (ICMR guidelines)
    IF p_bp_systolic IS NOT NULL AND p_bp_systolic > 180 THEN
        v_alert_needed := true;
        v_alert_message := 'CRITICAL: BP systolic > 180 mmHg. Seek immediate medical attention.';
    ELSIF p_bp_systolic IS NOT NULL AND p_bp_systolic > 140 THEN
        v_alert_needed := true;
        v_alert_message := 'WARNING: BP systolic > 140 mmHg (Stage 1 Hypertension per ICMR).';
    END IF;

    -- Check sugar thresholds
    IF p_sugar_fasting IS NOT NULL AND p_sugar_fasting > 200 THEN
        v_alert_needed := true;
        v_alert_message := COALESCE(v_alert_message || ' ', '') ||
            'CRITICAL: Fasting sugar > 200 mg/dL. Consult doctor immediately.';
    ELSIF p_sugar_fasting IS NOT NULL AND p_sugar_fasting > 125 THEN
        v_alert_needed := true;
        v_alert_message := COALESCE(v_alert_message || ' ', '') ||
            'WARNING: Fasting sugar 100-125 mg/dL (Pre-diabetic range per ICMR).';
    END IF;

    -- Create alert if needed
    IF v_alert_needed THEN
        INSERT INTO environmental_alerts (user_id, alert_type, alert_severity,
                                          alert_title, alert_description,
                                          alert_recommendation, location_city)
        VALUES (p_user_id, 'health_threshold', 
                CASE WHEN v_alert_message LIKE 'CRITICAL%' THEN 'critical' ELSE 'high' END,
                'Health Reading Alert', v_alert_message,
                'Please consult a healthcare professional for proper evaluation.',
                p_city);
    END IF;

    -- Update daily analytics
    INSERT INTO user_analytics (user_id, date, total_health_records_logged, app_opened, is_active_user)
    VALUES (p_user_id, CURRENT_DATE, 1, true, true)
    ON CONFLICT (user_id, date)
    DO UPDATE SET total_health_records_logged = user_analytics.total_health_records_logged + 1;

    COMMIT;
END;
$$;
```

### 5.3 Generate Analytics Report

```sql
CREATE OR REPLACE PROCEDURE sp_generate_analytics_report(
    p_user_id UUID,
    p_days INT DEFAULT 30
)
LANGUAGE plpgsql AS $$
DECLARE
    v_total_messages INT;
    v_total_records INT;
    v_avg_bp_systolic DECIMAL;
    v_avg_sugar DECIMAL;
    v_active_days INT;
BEGIN
    -- Calculate metrics
    SELECT COUNT(*) INTO v_total_messages
    FROM chat_history
    WHERE user_id = p_user_id AND created_at > NOW() - (p_days || ' days')::INTERVAL;

    SELECT COUNT(*) INTO v_total_records
    FROM health_records
    WHERE user_id = p_user_id AND recorded_at > NOW() - (p_days || ' days')::INTERVAL;

    SELECT AVG(blood_pressure_systolic) INTO v_avg_bp_systolic
    FROM health_records
    WHERE user_id = p_user_id
      AND record_type = 'vitals'
      AND blood_pressure_systolic IS NOT NULL
      AND recorded_at > NOW() - (p_days || ' days')::INTERVAL;

    SELECT AVG(blood_sugar_fasting) INTO v_avg_sugar
    FROM health_records
    WHERE user_id = p_user_id
      AND blood_sugar_fasting IS NOT NULL
      AND recorded_at > NOW() - (p_days || ' days')::INTERVAL;

    SELECT COUNT(DISTINCT date) INTO v_active_days
    FROM user_analytics
    WHERE user_id = p_user_id
      AND date > CURRENT_DATE - p_days
      AND is_active_user = true;

    RAISE NOTICE 'Analytics Report (% days):', p_days;
    RAISE NOTICE '  Messages sent: %', v_total_messages;
    RAISE NOTICE '  Health records: %', v_total_records;
    RAISE NOTICE '  Avg BP (systolic): %', ROUND(v_avg_bp_systolic, 1);
    RAISE NOTICE '  Avg fasting sugar: %', ROUND(v_avg_sugar, 1);
    RAISE NOTICE '  Active days: %/%', v_active_days, p_days;
END;
$$;
```

### 5.4 Process Environmental Alerts (Batch)

```sql
CREATE OR REPLACE PROCEDURE sp_process_environmental_alerts(
    p_city VARCHAR,
    p_aqi INT,
    p_temperature DECIMAL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_user RECORD;
    v_severity VARCHAR;
    v_title VARCHAR;
    v_description TEXT;
BEGIN
    -- Determine alert severity and content
    IF p_aqi > 400 THEN
        v_severity := 'critical';
        v_title := 'Hazardous Air Quality Alert';
        v_description := format('AQI has reached %s (Hazardous) in %s. All groups should avoid any outdoor activity.', p_aqi, p_city);
    ELSIF p_aqi > 300 THEN
        v_severity := 'high';
        v_title := 'Severe Air Quality Alert';
        v_description := format('AQI is %s (Severe) in %s. Avoid outdoor activities, use N95 mask.', p_aqi, p_city);
    ELSIF p_temperature > 42 THEN
        v_severity := 'high';
        v_title := 'Extreme Heatwave Alert';
        v_description := format('Temperature is %s°C in %s. Avoid sun 11am-3pm, stay hydrated.', p_temperature, p_city);
    ELSIF p_temperature < 4 THEN
        v_severity := 'moderate';
        v_title := 'Cold Wave Alert';
        v_description := format('Temperature is %s°C in %s. Layer clothing, warm fluids recommended.', p_temperature, p_city);
    ELSE
        RETURN; -- No alert needed
    END IF;

    -- Create alerts for all users in that city
    FOR v_user IN
        SELECT u.id FROM users u
        JOIN user_preferences up ON u.id = up.user_id
        WHERE u.preferred_city ILIKE p_city
          AND u.is_active = true
          AND up.notifications_enabled = true
          AND up.alert_aqi_threshold <= p_aqi
    LOOP
        INSERT INTO environmental_alerts (user_id, alert_type, alert_severity,
                                          alert_title, alert_description,
                                          location_city, aqi_value, temperature_celsius)
        VALUES (v_user.id,
                CASE WHEN p_aqi > 300 THEN 'aqi_spike'
                     WHEN p_temperature > 42 THEN 'heatwave'
                     ELSE 'cold_wave' END,
                v_severity, v_title, v_description,
                p_city, p_aqi, p_temperature);
    END LOOP;

    RAISE NOTICE 'Environmental alerts processed for city: %', p_city;
END;
$$;
```

### 5.5 Check and Downgrade Expired Subscriptions

```sql
CREATE OR REPLACE PROCEDURE sp_check_subscription_status()
LANGUAGE plpgsql AS $$
DECLARE
    v_expired RECORD;
    v_count INT := 0;
BEGIN
    FOR v_expired IN
        SELECT s.id AS sub_id, s.user_id, s.plan_type, u.email
        FROM subscriptions s
        JOIN users u ON s.user_id = u.id
        WHERE s.billing_status = 'active'
          AND s.plan_type != 'free'
          AND s.subscription_end_date < CURRENT_TIMESTAMP
          AND s.auto_renewal = false
    LOOP
        -- Downgrade subscription
        UPDATE subscriptions
        SET billing_status = 'cancelled', cancellation_date = CURRENT_TIMESTAMP,
            cancellation_reason = 'Auto-expired: subscription end date passed'
        WHERE id = v_expired.sub_id;

        -- Update user plan
        UPDATE users SET subscription_plan = 'free' WHERE id = v_expired.user_id;

        -- Create free subscription
        INSERT INTO subscriptions (user_id, plan_type, plan_name, billing_amount_inr,
                                   billing_cycle, billing_status)
        VALUES (v_expired.user_id, 'free', 'Free Tier (Downgraded)', 0, 'monthly', 'active');

        v_count := v_count + 1;
        RAISE NOTICE 'Downgraded subscription for user: %', v_expired.email;
    END LOOP;

    RAISE NOTICE 'Total subscriptions downgraded: %', v_count;
END;
$$;
```

---

## 6. Functions

### 6.1 Calculate BMI

```sql
CREATE OR REPLACE FUNCTION fn_calculate_bmi(
    p_weight_kg DECIMAL,
    p_height_cm DECIMAL
)
RETURNS TABLE(bmi DECIMAL, category VARCHAR) AS $$
DECLARE
    v_bmi DECIMAL;
BEGIN
    IF p_weight_kg IS NULL OR p_height_cm IS NULL OR p_height_cm = 0 THEN
        RETURN QUERY SELECT NULL::DECIMAL, 'Invalid input'::VARCHAR;
        RETURN;
    END IF;

    v_bmi := ROUND(p_weight_kg / ((p_height_cm / 100) ^ 2), 1);

    RETURN QUERY
    SELECT v_bmi,
        CASE
            WHEN v_bmi < 18.5 THEN 'Underweight'
            WHEN v_bmi < 23.0 THEN 'Normal (Asian BMI)'    -- Asian BMI cutoffs per WHO Asia-Pacific
            WHEN v_bmi < 25.0 THEN 'Overweight'
            WHEN v_bmi < 30.0 THEN 'Obese Class I'
            ELSE 'Obese Class II+'
        END::VARCHAR;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

### 6.2 Get AQI Level

```sql
CREATE OR REPLACE FUNCTION fn_get_aqi_level(p_aqi INT)
RETURNS VARCHAR AS $$
BEGIN
    RETURN CASE
        WHEN p_aqi <= 50  THEN 'Good'
        WHEN p_aqi <= 100 THEN 'Satisfactory'
        WHEN p_aqi <= 200 THEN 'Moderate'
        WHEN p_aqi <= 300 THEN 'Poor'
        WHEN p_aqi <= 400 THEN 'Severe'
        ELSE 'Hazardous'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

### 6.3 Check ICMR Range

```sql
CREATE OR REPLACE FUNCTION fn_check_icmr_range(
    p_metric VARCHAR,
    p_value DECIMAL
)
RETURNS TABLE(status VARCHAR, normal_range VARCHAR, recommendation TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE p_metric
            WHEN 'fasting_glucose' THEN
                CASE WHEN p_value < 70 THEN 'Low'
                     WHEN p_value <= 100 THEN 'Normal'
                     WHEN p_value <= 125 THEN 'Pre-diabetic'
                     ELSE 'Diabetic' END
            WHEN 'bp_systolic' THEN
                CASE WHEN p_value < 90 THEN 'Low'
                     WHEN p_value <= 120 THEN 'Normal'
                     WHEN p_value <= 139 THEN 'Elevated'
                     ELSE 'High' END
            WHEN 'hba1c' THEN
                CASE WHEN p_value < 5.7 THEN 'Normal'
                     WHEN p_value <= 6.4 THEN 'Pre-diabetic'
                     ELSE 'Diabetic' END
            WHEN 'cholesterol_total' THEN
                CASE WHEN p_value < 200 THEN 'Normal'
                     WHEN p_value <= 239 THEN 'Borderline'
                     ELSE 'High' END
            ELSE 'Unknown metric'
        END::VARCHAR,
        CASE p_metric
            WHEN 'fasting_glucose' THEN '70-100 mg/dL'
            WHEN 'bp_systolic' THEN '90-120 mmHg'
            WHEN 'hba1c' THEN '<5.7%'
            WHEN 'cholesterol_total' THEN '<200 mg/dL'
            ELSE 'N/A'
        END::VARCHAR,
        CASE p_metric
            WHEN 'fasting_glucose' THEN
                CASE WHEN p_value > 125 THEN 'Fasting glucose > 125 mg/dL. ICMR recommends consulting an endocrinologist.'
                     WHEN p_value > 100 THEN 'Pre-diabetic range (ICMR). Lifestyle modifications recommended.'
                     ELSE 'Within normal range per ICMR guidelines.' END
            WHEN 'bp_systolic' THEN
                CASE WHEN p_value > 140 THEN 'Stage 1 Hypertension (ICMR). Regular monitoring and doctor consultation advised.'
                     WHEN p_value > 120 THEN 'Elevated BP. Reduce sodium, increase exercise.'
                     ELSE 'Normal BP per ICMR guidelines.' END
            ELSE 'Consult healthcare professional for interpretation.'
        END::TEXT;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

### 6.4 Get User Health Summary

```sql
CREATE OR REPLACE FUNCTION fn_get_user_health_summary(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'user_id', p_user_id,
        'latest_bp', (
            SELECT jsonb_build_object('systolic', blood_pressure_systolic,
                                       'diastolic', blood_pressure_diastolic,
                                       'recorded_at', recorded_at)
            FROM health_records
            WHERE user_id = p_user_id AND blood_pressure_systolic IS NOT NULL
            ORDER BY recorded_at DESC LIMIT 1
        ),
        'latest_sugar', (
            SELECT jsonb_build_object('fasting', blood_sugar_fasting,
                                       'random', blood_sugar_random,
                                       'recorded_at', recorded_at)
            FROM health_records
            WHERE user_id = p_user_id AND blood_sugar_fasting IS NOT NULL
            ORDER BY recorded_at DESC LIMIT 1
        ),
        'active_conditions', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object(
                'condition', condition_name,
                'status', condition_status,
                'severity', severity_level
            )), '[]'::jsonb)
            FROM health_conditions
            WHERE user_id = p_user_id AND condition_status IN ('active', 'controlled')
        ),
        'total_records', (SELECT COUNT(*) FROM health_records WHERE user_id = p_user_id),
        'total_reports', (SELECT COUNT(*) FROM medical_reports WHERE user_id = p_user_id),
        'total_chats', (SELECT COUNT(*) FROM chat_history WHERE user_id = p_user_id),
        'generated_at', CURRENT_TIMESTAMP
    ) INTO v_result;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;
```

---

## 7. PL/SQL Packages

> **Note:** PostgreSQL doesn't natively support Oracle-style packages. We simulate packages using **schemas** as namespaces.

### 7.1 Health Analytics Package

```sql
CREATE SCHEMA IF NOT EXISTS pkg_health_analytics;

-- Function: Get BP trend
CREATE OR REPLACE FUNCTION pkg_health_analytics.get_bp_trend(
    p_user_id UUID, p_days INT DEFAULT 30
)
RETURNS TABLE(date DATE, avg_systolic DECIMAL, avg_diastolic DECIMAL, reading_count INT) AS $$
BEGIN
    RETURN QUERY
    SELECT recorded_at::DATE,
           ROUND(AVG(blood_pressure_systolic), 1),
           ROUND(AVG(blood_pressure_diastolic), 1),
           COUNT(*)::INT
    FROM health_records
    WHERE user_id = p_user_id
      AND blood_pressure_systolic IS NOT NULL
      AND recorded_at > NOW() - (p_days || ' days')::INTERVAL
    GROUP BY recorded_at::DATE
    ORDER BY recorded_at::DATE;
END;
$$ LANGUAGE plpgsql;

-- Function: Get sugar trend
CREATE OR REPLACE FUNCTION pkg_health_analytics.get_sugar_trend(
    p_user_id UUID, p_days INT DEFAULT 30
)
RETURNS TABLE(date DATE, avg_fasting DECIMAL, avg_random DECIMAL, reading_count INT) AS $$
BEGIN
    RETURN QUERY
    SELECT recorded_at::DATE,
           ROUND(AVG(blood_sugar_fasting), 1),
           ROUND(AVG(blood_sugar_random), 1),
           COUNT(*)::INT
    FROM health_records
    WHERE user_id = p_user_id
      AND (blood_sugar_fasting IS NOT NULL OR blood_sugar_random IS NOT NULL)
      AND recorded_at > NOW() - (p_days || ' days')::INTERVAL
    GROUP BY recorded_at::DATE
    ORDER BY recorded_at::DATE;
END;
$$ LANGUAGE plpgsql;

-- Function: Health risk score (0-100)
CREATE OR REPLACE FUNCTION pkg_health_analytics.calculate_risk_score(p_user_id UUID)
RETURNS TABLE(risk_score INT, risk_level VARCHAR, risk_factors TEXT[]) AS $$
DECLARE
    v_score INT := 0;
    v_factors TEXT[] := '{}';
    v_bp_systolic DECIMAL;
    v_sugar DECIMAL;
    v_bmi DECIMAL;
    v_conditions INT;
BEGIN
    -- Latest BP
    SELECT AVG(blood_pressure_systolic) INTO v_bp_systolic
    FROM health_records WHERE user_id = p_user_id
      AND blood_pressure_systolic IS NOT NULL
      AND recorded_at > NOW() - INTERVAL '7 days';

    IF v_bp_systolic > 140 THEN v_score := v_score + 25; v_factors := array_append(v_factors, 'Hypertension');
    ELSIF v_bp_systolic > 120 THEN v_score := v_score + 10; v_factors := array_append(v_factors, 'Elevated BP');
    END IF;

    -- Latest sugar
    SELECT AVG(blood_sugar_fasting) INTO v_sugar
    FROM health_records WHERE user_id = p_user_id
      AND blood_sugar_fasting IS NOT NULL
      AND recorded_at > NOW() - INTERVAL '7 days';

    IF v_sugar > 125 THEN v_score := v_score + 25; v_factors := array_append(v_factors, 'Diabetes risk');
    ELSIF v_sugar > 100 THEN v_score := v_score + 10; v_factors := array_append(v_factors, 'Pre-diabetes');
    END IF;

    -- Active conditions count
    SELECT COUNT(*) INTO v_conditions
    FROM health_conditions WHERE user_id = p_user_id AND condition_status = 'active';

    v_score := v_score + (v_conditions * 10);
    IF v_conditions > 0 THEN v_factors := array_append(v_factors, v_conditions || ' active conditions'); END IF;

    RETURN QUERY SELECT
        LEAST(v_score, 100),
        CASE WHEN v_score < 20 THEN 'Low' WHEN v_score < 50 THEN 'Moderate'
             WHEN v_score < 75 THEN 'High' ELSE 'Critical' END::VARCHAR,
        v_factors;
END;
$$ LANGUAGE plpgsql;
```

### 7.2 User Management Package

```sql
CREATE SCHEMA IF NOT EXISTS pkg_user_management;

-- Function: Deactivate inactive users
CREATE OR REPLACE FUNCTION pkg_user_management.deactivate_inactive_users(p_days INT DEFAULT 90)
RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    UPDATE users SET is_active = false
    WHERE last_login_at < NOW() - (p_days || ' days')::INTERVAL
      AND is_active = true
      AND deleted_at IS NULL;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Function: Soft delete user (GDPR / DPDP)
CREATE OR REPLACE FUNCTION pkg_user_management.soft_delete_user(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE users SET deleted_at = CURRENT_TIMESTAMP, is_active = false,
                     email = 'deleted_' || p_user_id || '@redacted.com',
                     phone = 'REDACTED', first_name = 'Deleted', last_name = 'User'
    WHERE id = p_user_id;

    UPDATE auth_sessions SET is_active = false, logged_out_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;

    RAISE NOTICE 'User % soft-deleted and PII redacted', p_user_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 8. Triggers

### 8.1 Auto-Update Timestamp

```sql
CREATE OR REPLACE FUNCTION trg_fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at column
CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION trg_fn_update_timestamp();

CREATE TRIGGER trg_health_records_updated_at BEFORE UPDATE ON health_records
    FOR EACH ROW EXECUTE FUNCTION trg_fn_update_timestamp();

CREATE TRIGGER trg_chat_history_updated_at BEFORE UPDATE ON chat_history
    FOR EACH ROW EXECUTE FUNCTION trg_fn_update_timestamp();

CREATE TRIGGER trg_medical_reports_updated_at BEFORE UPDATE ON medical_reports
    FOR EACH ROW EXECUTE FUNCTION trg_fn_update_timestamp();

CREATE TRIGGER trg_health_conditions_updated_at BEFORE UPDATE ON health_conditions
    FOR EACH ROW EXECUTE FUNCTION trg_fn_update_timestamp();

CREATE TRIGGER trg_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION trg_fn_update_timestamp();

CREATE TRIGGER trg_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION trg_fn_update_timestamp();
```

### 8.2 Audit Health Record Changes

```sql
CREATE TABLE IF NOT EXISTS health_records_audit (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    record_id UUID NOT NULL,
    user_id UUID NOT NULL,
    operation VARCHAR(10) NOT NULL,  -- INSERT, UPDATE, DELETE
    old_data JSONB,
    new_data JSONB,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100)
);

CREATE OR REPLACE FUNCTION trg_fn_audit_health_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO health_records_audit (record_id, user_id, operation, new_data)
        VALUES (NEW.id, NEW.user_id, 'INSERT', row_to_json(NEW)::JSONB);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO health_records_audit (record_id, user_id, operation, old_data, new_data)
        VALUES (NEW.id, NEW.user_id, 'UPDATE', row_to_json(OLD)::JSONB, row_to_json(NEW)::JSONB);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO health_records_audit (record_id, user_id, operation, old_data)
        VALUES (OLD.id, OLD.user_id, 'DELETE', row_to_json(OLD)::JSONB);
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_health_records
    AFTER INSERT OR UPDATE OR DELETE ON health_records
    FOR EACH ROW EXECUTE FUNCTION trg_fn_audit_health_changes();
```

### 8.3 Validate BP Range

```sql
CREATE OR REPLACE FUNCTION trg_fn_validate_bp_range()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.blood_pressure_systolic IS NOT NULL THEN
        IF NEW.blood_pressure_systolic < 40 OR NEW.blood_pressure_systolic > 300 THEN
            RAISE EXCEPTION 'Invalid systolic BP: %. Must be between 40-300 mmHg.', NEW.blood_pressure_systolic;
        END IF;
    END IF;

    IF NEW.blood_pressure_diastolic IS NOT NULL THEN
        IF NEW.blood_pressure_diastolic < 20 OR NEW.blood_pressure_diastolic > 200 THEN
            RAISE EXCEPTION 'Invalid diastolic BP: %. Must be between 20-200 mmHg.', NEW.blood_pressure_diastolic;
        END IF;
    END IF;

    IF NEW.blood_pressure_systolic IS NOT NULL AND NEW.blood_pressure_diastolic IS NOT NULL THEN
        IF NEW.blood_pressure_systolic <= NEW.blood_pressure_diastolic THEN
            RAISE EXCEPTION 'Systolic (%) must be greater than diastolic (%).', NEW.blood_pressure_systolic, NEW.blood_pressure_diastolic;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_bp_reading
    BEFORE INSERT OR UPDATE ON health_records
    FOR EACH ROW EXECUTE FUNCTION trg_fn_validate_bp_range();
```

### 8.4 Auto-Downgrade Expired Subscriptions

```sql
CREATE OR REPLACE FUNCTION trg_fn_auto_downgrade_subscription()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subscription_end_date < CURRENT_TIMESTAMP
       AND OLD.subscription_end_date >= CURRENT_TIMESTAMP
       AND NEW.auto_renewal = false THEN

        NEW.billing_status := 'cancelled';
        NEW.cancellation_date := CURRENT_TIMESTAMP;
        NEW.cancellation_reason := 'Auto-expired: end date passed without renewal';

        UPDATE users SET subscription_plan = 'free' WHERE id = NEW.user_id;

        RAISE NOTICE 'Subscription auto-downgraded for user %', NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_downgrade_subscription
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION trg_fn_auto_downgrade_subscription();
```

### 8.5 Log API Usage on Chat Insert

```sql
CREATE OR REPLACE FUNCTION trg_fn_log_chat_api_usage()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO api_usage (user_id, endpoint_path, http_method, model_used,
                           input_tokens, output_tokens, total_tokens,
                           estimated_cost_inr, response_status_code)
    VALUES (NEW.user_id, '/api/v1/chat/message', 'POST', NEW.model_used,
            NEW.tokens_used * 0.4, NEW.tokens_used * 0.6, NEW.tokens_used,
            ROUND((NEW.tokens_used / 1000000.0) * 6.25, 4), 200);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_chat_api_usage
    AFTER INSERT ON chat_history
    FOR EACH ROW EXECUTE FUNCTION trg_fn_log_chat_api_usage();
```

### 8.6 Emergency Alert Trigger

```sql
CREATE OR REPLACE FUNCTION trg_fn_emergency_alert_on_chat()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.contained_emergency_keywords = true THEN
        INSERT INTO environmental_alerts (user_id, alert_type, alert_severity,
                                          alert_title, alert_description,
                                          alert_recommendation)
        VALUES (NEW.user_id, 'health_emergency', 'critical',
                '🚨 Emergency Keywords Detected',
                'Emergency keywords were detected in your recent health conversation.',
                'If you are experiencing a medical emergency, please call 108 immediately.');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_emergency_alert_chat
    AFTER INSERT ON chat_history
    FOR EACH ROW
    WHEN (NEW.contained_emergency_keywords = true)
    EXECUTE FUNCTION trg_fn_emergency_alert_on_chat();
```

---

## 9. Cursors

### 9.1 Batch Subscription Expiry Report

```sql
CREATE OR REPLACE FUNCTION fn_subscription_expiry_report()
RETURNS TABLE(user_email VARCHAR, plan_type VARCHAR, days_remaining INT, action_needed VARCHAR) AS $$
DECLARE
    sub_cursor CURSOR FOR
        SELECT u.email, s.plan_type, s.subscription_end_date, s.auto_renewal
        FROM subscriptions s
        JOIN users u ON s.user_id = u.id
        WHERE s.billing_status = 'active' AND s.plan_type != 'free'
        ORDER BY s.subscription_end_date ASC;
    v_record RECORD;
    v_days INT;
BEGIN
    FOR v_record IN sub_cursor LOOP
        v_days := EXTRACT(DAY FROM v_record.subscription_end_date - CURRENT_TIMESTAMP);

        RETURN QUERY SELECT
            v_record.email::VARCHAR,
            v_record.plan_type::VARCHAR,
            v_days,
            CASE
                WHEN v_days < 0 THEN 'EXPIRED - Downgrade immediately'
                WHEN v_days <= 3 THEN 'CRITICAL - Expiring in ' || v_days || ' days'
                WHEN v_days <= 7 THEN 'WARNING - Send renewal reminder'
                WHEN v_days <= 30 THEN 'INFO - Upcoming renewal'
                ELSE 'OK'
            END::VARCHAR;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

### 9.2 Batch Health Anomaly Scanner

```sql
CREATE OR REPLACE FUNCTION fn_scan_health_anomalies(p_days INT DEFAULT 7)
RETURNS TABLE(user_email VARCHAR, anomaly_type VARCHAR, value DECIMAL, threshold VARCHAR) AS $$
DECLARE
    health_cursor CURSOR FOR
        SELECT u.email, hr.blood_pressure_systolic, hr.blood_pressure_diastolic,
               hr.blood_sugar_fasting, hr.blood_sugar_random
        FROM health_records hr
        JOIN users u ON hr.user_id = u.id
        WHERE hr.recorded_at > NOW() - (p_days || ' days')::INTERVAL
          AND hr.record_type = 'vitals';
    v_rec RECORD;
BEGIN
    FOR v_rec IN health_cursor LOOP
        IF v_rec.blood_pressure_systolic > 180 THEN
            RETURN QUERY SELECT v_rec.email::VARCHAR, 'Critical BP'::VARCHAR,
                v_rec.blood_pressure_systolic::DECIMAL, '>180 mmHg'::VARCHAR;
        END IF;
        IF v_rec.blood_sugar_fasting > 200 THEN
            RETURN QUERY SELECT v_rec.email::VARCHAR, 'Critical Sugar'::VARCHAR,
                v_rec.blood_sugar_fasting::DECIMAL, '>200 mg/dL'::VARCHAR;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

---

## 10. Views & Materialized Views

### 10.1 Regular Views

```sql
-- User Health Summary View
CREATE OR REPLACE VIEW vw_user_health_summary AS
SELECT u.id, u.first_name, u.email, u.preferred_city,
       COUNT(DISTINCT h.id) AS total_records,
       MAX(h.recorded_at) AS last_record_date,
       ROUND(AVG(CASE WHEN h.blood_pressure_systolic IS NOT NULL
                      THEN h.blood_pressure_systolic END), 1) AS avg_systolic,
       ROUND(AVG(CASE WHEN h.blood_sugar_fasting IS NOT NULL
                      THEN h.blood_sugar_fasting END), 1) AS avg_fasting_sugar
FROM users u
LEFT JOIN health_records h ON u.id = h.user_id
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.first_name, u.email, u.preferred_city;

-- Active Users (30 days)
CREATE OR REPLACE VIEW vw_active_users_30d AS
SELECT u.id, u.first_name, u.email,
       COUNT(c.id) AS messages_sent, MAX(c.created_at) AS last_message
FROM users u
JOIN chat_history c ON u.id = c.user_id AND c.created_at > NOW() - INTERVAL '30 days'
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.first_name, u.email
HAVING COUNT(c.id) > 0;

-- Corporate Dashboard View
CREATE OR REPLACE VIEW vw_corporate_dashboard AS
SELECT ca.id, ca.company_name,
       COUNT(DISTINCT cem.user_id) AS enrolled,
       COUNT(DISTINCT CASE WHEN cem.enrollment_status = 'active' THEN cem.user_id END) AS active,
       COUNT(DISTINCT h.id) FILTER (WHERE h.created_at > NOW() - INTERVAL '30 days') AS records_30d,
       COUNT(DISTINCT c.id) FILTER (WHERE c.created_at > NOW() - INTERVAL '30 days') AS messages_30d
FROM corporate_accounts ca
LEFT JOIN corporate_employee_mapping cem ON ca.id = cem.corporate_account_id
LEFT JOIN health_records h ON cem.user_id = h.user_id
LEFT JOIN chat_history c ON cem.user_id = c.user_id
WHERE ca.is_active = true
GROUP BY ca.id, ca.company_name;
```

### 10.2 Materialized Views (for dashboards)

```sql
-- Materialized: Daily platform stats (refreshed hourly via cron)
CREATE MATERIALIZED VIEW mv_platform_daily_stats AS
SELECT CURRENT_DATE AS stat_date,
       (SELECT COUNT(*) FROM users WHERE is_active = true) AS total_active_users,
       (SELECT COUNT(*) FROM users WHERE created_at::DATE = CURRENT_DATE) AS new_users_today,
       (SELECT COUNT(*) FROM chat_history WHERE created_at::DATE = CURRENT_DATE) AS messages_today,
       (SELECT COUNT(*) FROM health_records WHERE recorded_at::DATE = CURRENT_DATE) AS records_today,
       (SELECT COUNT(*) FROM medical_reports WHERE created_at::DATE = CURRENT_DATE) AS reports_today,
       (SELECT SUM(estimated_cost_inr) FROM api_usage WHERE created_at::DATE = CURRENT_DATE) AS api_cost_today,
       (SELECT COUNT(*) FROM subscriptions WHERE plan_type = 'premium' AND billing_status = 'active') AS premium_users
WITH DATA;

CREATE UNIQUE INDEX ON mv_platform_daily_stats (stat_date);

-- Refresh command (scheduled via pg_cron or application cron)
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_platform_daily_stats;
```

---

## 11. Advanced Indexing

```sql
-- B-Tree indexes (standard lookups)
CREATE INDEX idx_health_records_user_type ON health_records(user_id, record_type);
CREATE INDEX idx_chat_safety ON chat_history(safety_check_passed) WHERE safety_check_passed = false;

-- GIN indexes (JSONB full-content search)
CREATE INDEX idx_health_records_env_ctx ON health_records USING GIN (environmental_context);
CREATE INDEX idx_medical_reports_biomarkers ON medical_reports USING GIN (biomarkers);
CREATE INDEX idx_medical_reports_abnormal ON medical_reports USING GIN (abnormal_values);

-- Full-Text Search (GIN + tsvector)
CREATE INDEX idx_chat_fts ON chat_history USING GIN (to_tsvector('english', user_message));

-- Partial indexes (filter on common conditions)
CREATE INDEX idx_users_active_only ON users(id) WHERE is_active = true AND deleted_at IS NULL;
CREATE INDEX idx_sessions_active ON auth_sessions(user_id) WHERE is_active = true;
CREATE INDEX idx_alerts_critical ON environmental_alerts(user_id, created_at DESC) WHERE alert_severity = 'critical';

-- Covering indexes (index-only scans)
CREATE INDEX idx_health_records_covering ON health_records(user_id, recorded_at DESC)
    INCLUDE (blood_pressure_systolic, blood_pressure_diastolic, blood_sugar_fasting);
```

---

## 12. Partitioning Strategy

```sql
-- Range-partition chat_history by month (high-volume table)
CREATE TABLE chat_history_partitioned (
    LIKE chat_history INCLUDING ALL
) PARTITION BY RANGE (created_at);

CREATE TABLE chat_history_2026_01 PARTITION OF chat_history_partitioned
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE chat_history_2026_02 PARTITION OF chat_history_partitioned
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE chat_history_2026_03 PARTITION OF chat_history_partitioned
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
-- Auto-create future partitions via pg_partman extension

-- Range-partition api_usage by month
CREATE TABLE api_usage_partitioned (
    LIKE api_usage INCLUDING ALL
) PARTITION BY RANGE (created_at);
```

---

## 13. CTEs & Window Functions

### 13.1 User Health Trend with Moving Average (CTE + Window)

```sql
WITH daily_readings AS (
    SELECT user_id,
           recorded_at::DATE AS reading_date,
           AVG(blood_pressure_systolic) AS avg_systolic,
           AVG(blood_sugar_fasting) AS avg_fasting
    FROM health_records
    WHERE user_id = $1 AND recorded_at > NOW() - INTERVAL '30 days'
    GROUP BY user_id, recorded_at::DATE
),
with_moving_avg AS (
    SELECT reading_date, avg_systolic, avg_fasting,
           ROUND(AVG(avg_systolic) OVER (ORDER BY reading_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 1) AS bp_7day_moving_avg,
           ROUND(AVG(avg_fasting) OVER (ORDER BY reading_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 1) AS sugar_7day_moving_avg,
           LAG(avg_systolic) OVER (ORDER BY reading_date) AS prev_day_systolic,
           ROW_NUMBER() OVER (ORDER BY reading_date DESC) AS recency_rank
    FROM daily_readings
)
SELECT reading_date, avg_systolic, avg_fasting,
       bp_7day_moving_avg, sugar_7day_moving_avg,
       CASE WHEN avg_systolic > prev_day_systolic THEN '↑ Rising'
            WHEN avg_systolic < prev_day_systolic THEN '↓ Falling'
            ELSE '→ Stable' END AS bp_trend
FROM with_moving_avg
ORDER BY reading_date;
```

### 13.2 Top Users by Engagement (Window Functions)

```sql
SELECT u.id, u.first_name, u.email,
       COUNT(c.id) AS total_messages,
       RANK() OVER (ORDER BY COUNT(c.id) DESC) AS engagement_rank,
       PERCENT_RANK() OVER (ORDER BY COUNT(c.id) DESC) AS percentile,
       NTILE(4) OVER (ORDER BY COUNT(c.id) DESC) AS engagement_quartile
FROM users u
LEFT JOIN chat_history c ON u.id = c.user_id AND c.created_at > NOW() - INTERVAL '30 days'
WHERE u.is_active = true
GROUP BY u.id, u.first_name, u.email
ORDER BY total_messages DESC
LIMIT 50;
```

---

## 14. Transaction Management

### 14.1 ACID Demonstration — Health Record with Alerts

```sql
BEGIN;
    SAVEPOINT before_health_insert;

    -- Step 1: Insert health record
    INSERT INTO health_records (user_id, record_type, blood_pressure_systolic,
                                blood_pressure_diastolic, recorded_at)
    VALUES ('user-uuid-here', 'vitals', 160, 100, NOW());

    SAVEPOINT after_health_insert;

    -- Step 2: Update analytics (if this fails, rollback only this step)
    BEGIN
        UPDATE user_analytics SET total_health_records_logged = total_health_records_logged + 1
        WHERE user_id = 'user-uuid-here' AND date = CURRENT_DATE;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK TO after_health_insert;
        RAISE NOTICE 'Analytics update failed, continuing without it';
    END;

    -- Step 3: Create alert for elevated BP
    INSERT INTO environmental_alerts (user_id, alert_type, alert_severity,
                                      alert_title, alert_recommendation)
    VALUES ('user-uuid-here', 'health_threshold', 'high',
            'Elevated BP Detected', 'Your BP reading is 160/100. Please consult a doctor.');

COMMIT;
```

### 14.2 Isolation Levels

```sql
-- For health record reads: READ COMMITTED (default, prevents dirty reads)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- For financial operations (subscriptions): SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
    -- Subscription upgrade logic here
COMMIT;
```

---

## 15. Row-Level Security

```sql
-- Enable RLS on sensitive tables
ALTER TABLE health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_reports ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own health records
CREATE POLICY policy_health_records_user_isolation ON health_records
    FOR ALL
    USING (user_id = current_setting('app.current_user_id')::UUID);

CREATE POLICY policy_chat_history_user_isolation ON chat_history
    FOR ALL
    USING (user_id = current_setting('app.current_user_id')::UUID);

CREATE POLICY policy_medical_reports_user_isolation ON medical_reports
    FOR ALL
    USING (user_id = current_setting('app.current_user_id')::UUID);

-- Usage in application:
-- SET LOCAL app.current_user_id = 'user-uuid-here';
-- SELECT * FROM health_records;  -- Only returns this user's records
```

---

## Summary

| Feature | Count/Details |
|---------|--------------|
| **Entities (ER)** | 15 tables + 1 audit table |
| **Custom Types** | 7 ENUMs + 6 Domains |
| **Stored Procedures** | 5 (`sp_create_user`, `sp_log_health_record`, `sp_generate_analytics_report`, `sp_process_environmental_alerts`, `sp_check_subscription_status`) |
| **Functions** | 4 standalone + 5 in packages (`fn_calculate_bmi`, `fn_get_aqi_level`, `fn_check_icmr_range`, `fn_get_user_health_summary`) |
| **Packages (Schemas)** | 2 (`pkg_health_analytics`, `pkg_user_management`) |
| **Triggers** | 6 types, 10+ trigger instances |
| **Cursors** | 2 explicit cursor functions |
| **Views** | 3 regular + 1 materialized |
| **Advanced Indexes** | B-Tree, GIN, Full-Text, Partial, Covering |
| **Partitioning** | Range partitioning on `chat_history` and `api_usage` |
| **CTE + Window Functions** | Moving averages, rankings, percentiles |
| **RLS Policies** | 3 tables with user-isolation policies |

---

**Document Status:** ✅ Complete
**Version:** 3.0 | **Last Updated:** March 10, 2026
