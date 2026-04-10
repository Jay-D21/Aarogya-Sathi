-- 07_seed_data.sql
-- Mock Data for Aarogya Sathi Database

-- We use DO blocks to avoid UUID hardcoding issues while allowing relational inserts
DO $$
DECLARE
    u1_id UUID;
    u2_id UUID;
    u3_id UUID;
    c1_id UUID;
BEGIN
    -- 1. Create Users
    -- Note we use the SP to create User 1 (Raj) to get all auto-generated content
    CALL sp_create_user(
        'raj.kumar@example.com', '+919876543210', 'hashed_pass_1', 
        'Raj', 'Kumar', '1980-05-15', 'male', 175.5,
        u1_id
    );

    -- Create User 2 (Priya)
    CALL sp_create_user(
        'priya.s@example.com', '+919876543211', 'hashed_pass_2', 
        'Priya', 'Sharma', '1992-08-20', 'female', 160.0,
        u2_id
    );

    -- Create User 3 (Amit)
    CALL sp_create_user(
        'amit.patel@example.com', '+919876543212', 'hashed_pass_3', 
        'Amit', 'Patel', '1975-11-05', 'male', 180.0,
        u3_id
    );

    -- Update preferred cities
    UPDATE users SET preferred_city = 'Delhi' WHERE id = u1_id;
    UPDATE users SET preferred_city = 'Mumbai' WHERE id = u2_id;
    UPDATE users SET preferred_city = 'Pune' WHERE id = u3_id;

    -- Update subscription for u2 to premium
    UPDATE subscriptions SET plan_type = 'premium', plan_name = 'Aarogya Sathi Premium', billing_cycle = 'yearly', 
    subscription_end_date = CURRENT_TIMESTAMP + interval '1 year' WHERE user_id = u2_id;
    
    -- Update subscription for u3 to expired premium (for testing)
    UPDATE subscriptions SET plan_type = 'premium', plan_name = 'Aarogya Sathi Premium', billing_cycle = 'monthly', 
    subscription_end_date = CURRENT_TIMESTAMP - interval '1 day', auto_renewal = FALSE WHERE user_id = u3_id;


    -- 2. Health Records
    -- U1 (Raj) has hypertension
    INSERT INTO health_records (user_id, record_type, blood_pressure_systolic, blood_pressure_diastolic, weight_kg, recorded_at)
    VALUES 
        (u1_id, 'vitals', 145, 95, 85.0, CURRENT_TIMESTAMP - interval '3 days'),
        (u1_id, 'vitals', 142, 90, 84.5, CURRENT_TIMESTAMP - interval '1 day'),
        (u1_id, 'vitals', 138, 88, 84.5, CURRENT_TIMESTAMP);
        
    -- U2 (Priya) has perfect vitals
    INSERT INTO health_records (user_id, record_type, blood_pressure_systolic, blood_pressure_diastolic, blood_sugar_random, weight_kg, recorded_at)
    VALUES 
        (u2_id, 'vitals', 115, 75, 95, 58.0, CURRENT_TIMESTAMP - interval '2 days'),
        (u2_id, 'vitals', 118, 78, 100, 58.5, CURRENT_TIMESTAMP);

    -- U3 (Amit) has severe diabetes
    INSERT INTO health_records (user_id, record_type, blood_sugar_fasting, blood_sugar_pp, weight_kg, recorded_at)
    VALUES 
        (u3_id, 'vitals', 180, 250, 95.0, CURRENT_TIMESTAMP - interval '4 days'),
        (u3_id, 'vitals', 170, 240, 95.0, CURRENT_TIMESTAMP - interval '1 day'),
        (u3_id, 'vitals', 165, 220, 94.5, CURRENT_TIMESTAMP);

    -- 3. Health Conditions
    INSERT INTO health_conditions (user_id, condition_name, condition_category, severity_level)
    VALUES 
        (u1_id, 'Hypertension', 'chronic', 'moderate'),
        (u3_id, 'Type 2 Diabetes', 'chronic', 'severe');

    -- 4. Chat History
    INSERT INTO chat_history (user_id, user_message, ai_response, tokens_used, message_language)
    VALUES 
        (u1_id, 'My BP is 145/95 today, should I be worried?', 'Your BP is slightly elevated. Continue your prescribed medication and monitor daily. Avoid salty foods today. ⚠️ Consult a doctor for diagnosis and treatment.', 150, 'en'),
        (u2_id, 'What is the AQI in Mumbai today?', 'The AQI in Mumbai is currently 150 (Moderate). It is safe for most people, but sensitive individuals should limit prolonged outdoor exertion. ⚠️ This is health awareness information only.', 120, 'en'),
        (u3_id, 'I had a heavy meal and my sugar is 250.', 'A post-meal sugar of 250 is high. Please go for a 15-minute walk if possible, drink water, and consult your endocrinologist if it remains high. ⚠️ Only a qualified doctor can provide medical advice.', 180, 'en');

    -- 5. Daily Steps
    INSERT INTO daily_steps (user_id, log_date, steps_count, distance_km, calories_burned)
    VALUES 
        (u1_id, CURRENT_DATE - 1, 8500, 6.5, 320),
        (u1_id, CURRENT_DATE, 4000, 3.0, 150),  -- Will update to >10k in demo to fire trigger
        (u2_id, CURRENT_DATE, 12500, 9.5, 480);

    -- 5b. Also insert a critical health reading so fn_scan_health_anomalies detects it
    INSERT INTO health_records (user_id, record_type, blood_pressure_systolic, blood_pressure_diastolic, recorded_at)
    VALUES (u1_id, 'vitals', 190, 110, CURRENT_TIMESTAMP - interval '2 days');

    -- 6. Corporate Account
    INSERT INTO corporate_accounts (company_name, company_registration_number, industry, employee_count, location_city, primary_contact_email, primary_contact_phone)
    VALUES ('TechWave Solutions', 'REG12345', 'IT', 500, 'Mumbai', 'hr@techwave.com', '+919800000001')
    RETURNING id INTO c1_id;

    -- Add Priya to TechWave
    INSERT INTO corporate_employee_mapping (corporate_account_id, user_id, employee_id, employee_name, employee_email, department)
    VALUES (c1_id, u2_id, 'EMP001', 'Priya Sharma', 'priya.s@techwave.com', 'Engineering');

    -- 7. Reminders
    INSERT INTO reminders (user_id, title, category, reminder_time, frequency, is_active)
    VALUES
        (u1_id, 'Take BP Medication', 'medication', '08:00:00', 'daily', true),
        (u2_id, 'Drink Water', 'water', '10:00:00', 'daily', true),
        (u3_id, 'Check Fasting Sugar', 'custom', '07:00:00', 'daily', true);

    -- 8. Workouts
    INSERT INTO workouts (user_id, workout_type, start_time, end_time, duration_minutes, intensity, calories_burned)
    VALUES
        (u2_id, 'yoga', CURRENT_TIMESTAMP - interval '3 hours', CURRENT_TIMESTAMP - interval '2 hours', 60, 'moderate', 250);

    -- 9. User Feedback
    INSERT INTO user_feedback (user_id, feedback_type, overall_rating, feedback_title, feedback_description)
    VALUES (u2_id, 'general', 5, 'Amazing app!', 'The health tracking and AI chat features are very helpful.');

    -- 10. Environmental Alerts (from weather)
    INSERT INTO environmental_alerts (user_id, alert_type, alert_severity, alert_title, alert_description, location_city, aqi_value)
    VALUES (u1_id, 'aqi_spike', 'high', 'Poor Air Quality', 'AQI in Delhi has risen to 280. Limit outdoor exposure.', 'Delhi', 280);

END $$;
