-- 04_procedures_and_functions.sql
-- Procedures and Functions for Aarogya Sathi

-- 1. Create schema for packages
CREATE SCHEMA IF NOT EXISTS pkg_health_analytics;
CREATE SCHEMA IF NOT EXISTS pkg_user_management;

-- 2. Stored Procedures

-- SP 1: Create User with auto-features
CREATE OR REPLACE PROCEDURE sp_create_user(
    p_email VARCHAR,
    p_phone VARCHAR,
    p_password_hash VARCHAR,
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_dob DATE,
    p_gender user_gender,
    p_height_cm DECIMAL,
    OUT p_user_id UUID
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert into users
    INSERT INTO users (email, phone, password_hash, first_name, last_name, date_of_birth, gender, height_cm)
    VALUES (p_email, p_phone, p_password_hash, p_first_name, p_last_name, p_dob, p_gender, p_height_cm)
    RETURNING id INTO p_user_id;

    -- Create default preferences
    INSERT INTO user_preferences (user_id) VALUES (p_user_id);
    
    -- Create free subscription
    INSERT INTO subscriptions (user_id, plan_type, plan_name, billing_status)
    VALUES (p_user_id, 'free', 'Aarogya Sathi Basic', 'active');
END;
$$;

-- SP 2: Log Health Record
-- Note: COMMIT removed as per master review
CREATE OR REPLACE PROCEDURE sp_log_health_record(
    p_user_id UUID,
    p_sys_bp INT,
    p_dia_bp INT,
    p_sugar INT,
    p_notes TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_record_id UUID;
    v_alert_created BOOLEAN := FALSE;
BEGIN
    -- 1. Insert Record
    INSERT INTO health_records (
        user_id, record_type, blood_pressure_systolic, blood_pressure_diastolic, 
        blood_sugar_random, notes, recorded_at
    ) VALUES (
        p_user_id, 'vitals', p_sys_bp, p_dia_bp, p_sugar, p_notes, CURRENT_TIMESTAMP
    ) RETURNING id INTO v_record_id;

    -- 2. Check ICMR Thresholds & Auto-alert
    IF p_sys_bp > 140 OR p_dia_bp > 90 THEN
        INSERT INTO environmental_alerts (
            user_id, alert_type, alert_severity, alert_title, alert_description, triggering_metric, triggering_value
        ) VALUES (
            p_user_id, 'health_threshold', 'high', 'High Blood Pressure Alert',
            'Your recent BP reading (' || p_sys_bp || '/' || p_dia_bp || ') is above normal ICMR guidelines.',
            'blood_pressure_systolic', p_sys_bp
        );
        v_alert_created := TRUE;
    END IF;

    IF p_sugar > 200 THEN
        INSERT INTO environmental_alerts (
            user_id, alert_type, alert_severity, alert_title, alert_description, triggering_metric, triggering_value
        ) VALUES (
            p_user_id, 'health_threshold', 'high', 'High Blood Sugar Alert',
            'Your recent random blood sugar reading (' || p_sugar || ') is critically high.',
            'blood_sugar_random', p_sugar
        );
        v_alert_created := TRUE;
    END IF;
    
    -- Let caller manage transaction.
END;
$$;

-- SP 3: Generate Analytics Report
CREATE OR REPLACE PROCEDURE sp_generate_analytics_report(
    p_user_id UUID,
    p_days INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_date DATE := CURRENT_DATE - p_days;
BEGIN
    -- UPSERT analytics for the given range
    INSERT INTO user_analytics (
        user_id, date, total_messages_sent, total_health_records_logged
    )
    SELECT 
        p_user_id, CURRENT_DATE,
        (SELECT COUNT(*) FROM chat_history WHERE user_id = p_user_id AND created_at >= v_start_date),
        (SELECT COUNT(*) FROM health_records WHERE user_id = p_user_id AND created_at >= v_start_date)
    ON CONFLICT (user_id, date) 
    DO UPDATE SET 
        total_messages_sent = EXCLUDED.total_messages_sent,
        total_health_records_logged = EXCLUDED.total_health_records_logged,
        updated_at = CURRENT_TIMESTAMP;
END;
$$;

-- SP 4: Process Environmental Alerts
CREATE OR REPLACE PROCEDURE sp_process_environmental_alerts(
    p_city VARCHAR,
    p_aqi INT,
    p_temp DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- If AQI is severe, alert all users in that city
    IF p_aqi > 300 THEN
        INSERT INTO environmental_alerts (
            user_id, alert_type, alert_severity, alert_title, alert_description, location_city, aqi_value
        )
        SELECT 
            id, 'aqi_spike', 'critical', 'Severe Air Pollution Alert',
            'AQI is ' || p_aqi || '. Please avoid outdoor activities and use an N95 mask.',
            p_city, p_aqi
        FROM users 
        WHERE preferred_city = p_city AND is_active = TRUE;
    END IF;

    -- If Heatwave, alert all users in that city
    IF p_temp > 40 THEN
        INSERT INTO environmental_alerts (
            user_id, alert_type, alert_severity, alert_title, alert_description, location_city, temperature_celsius
        )
        SELECT 
            id, 'heatwave', 'critical', 'Heatwave Alert',
            'Temperature is ' || p_temp || '°C. Stay hydrated and avoid direct sun.',
            p_city, p_temp
        FROM users 
        WHERE preferred_city = p_city AND is_active = TRUE;
    END IF;
END;
$$;

-- SP 5: Check Subscription Status
CREATE OR REPLACE PROCEDURE sp_check_subscription_status()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Downgrade expired premium subscriptions
    UPDATE subscriptions
    SET plan_type = 'free',
        billing_status = 'cancelled',
        updated_at = CURRENT_TIMESTAMP
    WHERE plan_type != 'free' 
      AND subscription_end_date < CURRENT_TIMESTAMP
      AND auto_renewal = FALSE;
END;
$$;

-- SP 6: Evaluate Step Goal
CREATE OR REPLACE PROCEDURE sp_evaluate_step_goal(
    p_user_id UUID,
    p_date DATE,
    p_steps INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_target INT;
BEGIN
    SELECT target_daily_steps INTO v_target 
    FROM user_preferences 
    WHERE user_id = p_user_id;

    IF v_target IS NULL THEN v_target := 10000; END IF;

    IF p_steps >= v_target THEN
        -- Reward or congratulate: we can insert a pseudo alert or just a chat message
        INSERT INTO chat_history (user_id, user_message, ai_response, safety_check_passed)
        VALUES (p_user_id, 'System Update: Goal Reached', 'Congratulations! You reached your daily step goal of ' || v_target || ' steps!', true);
    END IF;
END;
$$;


-- 3. Standalone Functions

-- Function: Calculate BMI
CREATE OR REPLACE FUNCTION fn_calculate_bmi(weight_kg DECIMAL, height_cm DECIMAL)
RETURNS TABLE (bmi DECIMAL, category VARCHAR) 
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    calc_bmi DECIMAL;
    cat VARCHAR;
    height_m DECIMAL := height_cm / 100.0;
BEGIN
    IF height_cm = 0 THEN
        calc_bmi := 0;
        cat := 'Invalid Height';
    ELSE
        calc_bmi := ROUND((weight_kg / (height_m * height_m))::NUMERIC, 2);
        
        -- Asian BMI cutoffs
        IF calc_bmi < 18.5 THEN cat := 'Underweight';
        ELSIF calc_bmi < 23 THEN cat := 'Normal';
        ELSIF calc_bmi < 27.5 THEN cat := 'Overweight';
        ELSE cat := 'Obese';
        END IF;
    END IF;
    
    RETURN QUERY SELECT calc_bmi, cat;
END;
$$;

-- Function: Get AQI Level
CREATE OR REPLACE FUNCTION fn_get_aqi_level(aqi INT)
RETURNS VARCHAR
LANGUAGE plpgsql IMMUTABLE
AS $$
BEGIN
    IF aqi <= 50 THEN RETURN 'Good';
    ELSIF aqi <= 100 THEN RETURN 'Satisfactory';
    ELSIF aqi <= 200 THEN RETURN 'Moderate';
    ELSIF aqi <= 300 THEN RETURN 'Poor';
    ELSIF aqi <= 400 THEN RETURN 'Severe';
    ELSE RETURN 'Hazardous';
    END IF;
END;
$$;

-- Function: Check ICMR range
CREATE OR REPLACE FUNCTION fn_check_icmr_range(p_metric VARCHAR, p_value DECIMAL)
RETURNS TABLE (status VARCHAR, normal_range VARCHAR, recommendation TEXT)
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    v_status VARCHAR;
    v_range VARCHAR;
    v_rec TEXT;
BEGIN
    IF p_metric = 'systolic_bp' THEN
        v_range := '< 120 mmHg';
        IF p_value < 120 THEN 
            v_status := 'Normal'; v_rec := 'Maintain healthy lifestyle.';
        ELSIF p_value <= 139 THEN 
            v_status := 'Prehypertension'; v_rec := 'Monitor salt intake, exercise regularly, reduce stress.';
        ELSE 
            v_status := 'Hypertension'; v_rec := 'Consult a doctor, reduce sodium to <5g/day, start medication if prescribed.';
        END IF;
    ELSIF p_metric = 'diastolic_bp' THEN
        v_range := '< 80 mmHg';
        IF p_value < 80 THEN 
            v_status := 'Normal'; v_rec := 'Maintain healthy lifestyle.';
        ELSIF p_value <= 89 THEN 
            v_status := 'Prehypertension'; v_rec := 'Monitor regularly, reduce salt.';
        ELSE 
            v_status := 'Hypertension'; v_rec := 'Consult doctor immediately.';
        END IF;
    ELSIF p_metric = 'fasting_sugar' THEN
        v_range := '70-100 mg/dL';
        IF p_value < 70 THEN 
            v_status := 'Hypoglycemia'; v_rec := 'Eat something immediately. If recurring, consult doctor.';
        ELSIF p_value <= 100 THEN 
            v_status := 'Normal'; v_rec := 'Maintain dietary habits.';
        ELSIF p_value <= 125 THEN 
            v_status := 'Prediabetes'; v_rec := 'Reduce refined carbs, increase physical activity to 150min/week.';
        ELSE 
            v_status := 'Diabetes'; v_rec := 'Consult endocrinologist, monitor HbA1c regularly.';
        END IF;
    ELSIF p_metric = 'random_sugar' THEN
        v_range := '< 140 mg/dL';
        IF p_value < 140 THEN 
            v_status := 'Normal'; v_rec := 'Maintain dietary habits.';
        ELSIF p_value <= 199 THEN 
            v_status := 'Prediabetes'; v_rec := 'Get fasting glucose test. Reduce sugary foods.';
        ELSE 
            v_status := 'Diabetes'; v_rec := 'Consult endocrinologist urgently.';
        END IF;
    ELSE
        v_status := 'Unknown Metric'; v_range := 'N/A'; v_rec := 'Metric not recognized. Consult doctor.';
    END IF;
    
    RETURN QUERY SELECT v_status, v_range, v_rec;
END;
$$;

-- Function: Get Health Summary
CREATE OR REPLACE FUNCTION fn_get_user_health_summary(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_res JSONB;
BEGIN
    SELECT jsonb_build_object(
        'latest_sys_bp', (SELECT blood_pressure_systolic FROM health_records WHERE user_id = p_user_id AND blood_pressure_systolic IS NOT NULL ORDER BY recorded_at DESC LIMIT 1),
        'latest_dia_bp', (SELECT blood_pressure_diastolic FROM health_records WHERE user_id = p_user_id AND blood_pressure_diastolic IS NOT NULL ORDER BY recorded_at DESC LIMIT 1),
        'latest_sugar', (SELECT COALESCE(blood_sugar_fasting, blood_sugar_random) FROM health_records WHERE user_id = p_user_id AND (blood_sugar_fasting IS NOT NULL OR blood_sugar_random IS NOT NULL) ORDER BY recorded_at DESC LIMIT 1),
        'conditions', (SELECT jsonb_agg(condition_name) FROM health_conditions WHERE user_id = p_user_id AND condition_status = 'active')
    ) INTO v_res;
    RETURN COALESCE(v_res, '{}'::JSONB);
END;
$$;

-- 4. Packages

-- Package: pkg_health_analytics
CREATE OR REPLACE FUNCTION pkg_health_analytics.get_bp_trend(p_user_id UUID, p_days INT)
RETURNS TABLE (rec_date DATE, avg_sys NUMERIC, avg_dia NUMERIC)
LANGUAGE sql STABLE
AS $$
    SELECT 
        DATE(recorded_at) as rec_date, 
        ROUND(AVG(blood_pressure_systolic), 2), 
        ROUND(AVG(blood_pressure_diastolic), 2)
    FROM health_records
    WHERE user_id = p_user_id 
      AND record_type = 'vitals' 
      AND recorded_at >= CURRENT_DATE - p_days
      AND blood_pressure_systolic IS NOT NULL
    GROUP BY DATE(recorded_at)
    ORDER BY rec_date;
$$;

CREATE OR REPLACE FUNCTION pkg_health_analytics.get_sugar_trend(p_user_id UUID, p_days INT)
RETURNS TABLE (rec_date DATE, avg_sugar NUMERIC)
LANGUAGE sql STABLE
AS $$
    SELECT 
        DATE(recorded_at) as rec_date, 
        ROUND(AVG(COALESCE(blood_sugar_fasting, blood_sugar_random, blood_sugar_pp)), 2)
    FROM health_records
    WHERE user_id = p_user_id 
      AND record_type = 'vitals' 
      AND recorded_at >= CURRENT_DATE - p_days
      AND (blood_sugar_fasting IS NOT NULL OR blood_sugar_random IS NOT NULL OR blood_sugar_pp IS NOT NULL)
    GROUP BY DATE(recorded_at)
    ORDER BY rec_date;
$$;

CREATE OR REPLACE FUNCTION pkg_health_analytics.calculate_risk_score(p_user_id UUID)
RETURNS TABLE (score INT, risk_level VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_score INT := 0;
    v_sys INT;
    v_sugar INT;
    v_bmi DECIMAL;
    v_weight DECIMAL;
    v_height DECIMAL;
BEGIN
    SELECT blood_pressure_systolic INTO v_sys FROM health_records WHERE user_id = p_user_id AND blood_pressure_systolic IS NOT NULL ORDER BY recorded_at DESC LIMIT 1;
    SELECT blood_sugar_random INTO v_sugar FROM health_records WHERE user_id = p_user_id AND blood_sugar_random IS NOT NULL ORDER BY recorded_at DESC LIMIT 1;
    
    SELECT weight_kg INTO v_weight FROM health_records WHERE user_id = p_user_id AND weight_kg IS NOT NULL ORDER BY recorded_at DESC LIMIT 1;
    SELECT height_cm INTO v_height FROM users WHERE id = p_user_id;

    IF v_sys > 140 THEN v_score := v_score + 30; END IF;
    IF v_sugar > 200 THEN v_score := v_score + 30; END IF;
    
    IF v_weight IS NOT NULL AND v_height IS NOT NULL AND v_height > 0 THEN
        v_bmi := (v_weight / ((v_height/100) * (v_height/100)));
        IF v_bmi > 27.5 THEN v_score := v_score + 20; END IF;
    END IF;
    
    IF v_score > 50 THEN risk_level := 'High';
    ELSIF v_score > 20 THEN risk_level := 'Moderate';
    ELSE risk_level := 'Low';
    END IF;
    
    score := v_score;
    RETURN NEXT;
END;
$$;

-- Package: pkg_user_management
CREATE OR REPLACE FUNCTION pkg_user_management.deactivate_inactive_users(p_days INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_updated INT;
BEGIN
    UPDATE users 
    SET is_active = FALSE, updated_at = CURRENT_TIMESTAMP
    WHERE last_login_at < CURRENT_TIMESTAMP - (p_days || ' days')::interval
      AND is_active = TRUE;
      
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RETURN v_updated;
END;
$$;

CREATE OR REPLACE FUNCTION pkg_user_management.soft_delete_user(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_short_id TEXT := LEFT(p_user_id::TEXT, 8); -- Short unique suffix
BEGIN
    -- Redact PII (DPDP Act compliance)
    UPDATE users 
    SET deleted_at = CURRENT_TIMESTAMP, 
        is_active = FALSE,
        email = 'deleted.' || v_short_id || '@redacted.com',
        phone = '+91' || LPAD(FLOOR(RANDOM() * 10000000)::TEXT, 10, '0'),
        first_name = 'Redacted',
        last_name = 'Redacted',
        date_of_birth = NULL,
        height_cm = NULL,
        abha_id = NULL
    WHERE id = p_user_id AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN FALSE; -- User not found or already deleted
    END IF;
    
    -- Invalidate all active sessions
    UPDATE auth_sessions 
    SET is_active = FALSE, logged_out_at = CURRENT_TIMESTAMP 
    WHERE user_id = p_user_id AND is_active = TRUE;
    
    RETURN TRUE;
END;
$$;

-- 5. Cursor Functions

CREATE OR REPLACE FUNCTION fn_subscription_expiry_report()
RETURNS TABLE (user_email VARCHAR, plan VARCHAR, days_remaining INT)
LANGUAGE plpgsql
AS $$
DECLARE
    cur_subs CURSOR FOR 
        SELECT u.email, s.plan_type, EXTRACT(DAY FROM (s.subscription_end_date - CURRENT_TIMESTAMP))::INT as days
        FROM subscriptions s
        JOIN users u ON s.user_id = u.id
        WHERE s.plan_type != 'free' AND s.subscription_end_date IS NOT NULL;
    v_rec RECORD;
BEGIN
    FOR v_rec IN cur_subs LOOP
        user_email := v_rec.email;
        plan := v_rec.plan_type::VARCHAR;
        days_remaining := v_rec.days;
        RETURN NEXT;
    END LOOP;
END;
$$;


CREATE OR REPLACE FUNCTION fn_scan_health_anomalies(p_days INT)
RETURNS TABLE (r_user_id UUID, r_metric VARCHAR, r_value NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    cur_anomalies CURSOR FOR 
        SELECT user_id, 
               CASE 
                 WHEN blood_pressure_systolic > 180 THEN 'Critical High BP'
                 WHEN blood_sugar_random > 300 THEN 'Critical High Sugar'
                 WHEN blood_sugar_fasting < 70 THEN 'Hypoglycemia'
                 ELSE NULL
               END as metric,
               CASE 
                 WHEN blood_pressure_systolic > 180 THEN blood_pressure_systolic
                 WHEN blood_sugar_random > 300 THEN blood_sugar_random
                 WHEN blood_sugar_fasting < 70 THEN blood_sugar_fasting
                 ELSE NULL
               END as val
        FROM health_records
        WHERE recorded_at >= CURRENT_TIMESTAMP - (p_days || ' days')::interval;
    v_rec RECORD;
BEGIN
    FOR v_rec IN cur_anomalies LOOP
        IF v_rec.metric IS NOT NULL THEN
            r_user_id := v_rec.user_id;
            r_metric := v_rec.metric;
            r_value := v_rec.val;
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$;
