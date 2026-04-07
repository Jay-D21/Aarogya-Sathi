-- 08_demo_working.sql
-- 20 Demos to prove the database works correctly.

-- DEMO 1: Test sp_create_user (creates preferences + free subscription)
-- We will just select to show they were created for Raj Kumar
SELECT u.email, sp.plan_type, p.notifications_enabled 
FROM users u
JOIN subscriptions sp ON u.id = sp.user_id
JOIN user_preferences p ON u.id = p.user_id
WHERE u.email = 'raj.kumar@example.com';

-- DEMO 2: Test sp_log_health_record with critical BP -> Should create Alert
DO $$
DECLARE v_usr UUID;
BEGIN
    SELECT id INTO v_usr FROM users WHERE email = 'raj.kumar@example.com';
    -- 180 is high sys bp -> creates alert
    CALL sp_log_health_record(v_usr, 185, 100, 110, 'Felt dizzy');
END $$;
-- Now verify the alert was created
SELECT alert_title, alert_description FROM environmental_alerts WHERE alert_title LIKE 'High Blood Pressure Alert%' ORDER BY created_at DESC LIMIT 1;


-- DEMO 3: Test Emergency Alert Trigger
DO $$
DECLARE v_usr UUID;
BEGIN
    SELECT id INTO v_usr FROM users WHERE email = 'priya.s@example.com';
    INSERT INTO chat_history (user_id, user_message, ai_response, contained_emergency_keywords)
    VALUES (v_usr, 'I have terrible chest pain', 'Please call 108', true);
END $$;
-- Verify
SELECT alert_type, alert_title FROM environmental_alerts WHERE user_id = (SELECT id FROM users WHERE email = 'priya.s@example.com') AND alert_type = 'health_emergency';


-- DEMO 4: Test fn_calculate_bmi
SELECT * FROM fn_calculate_bmi(85.0, 175.5);

-- DEMO 5: Test fn_check_icmr_range
SELECT * FROM fn_check_icmr_range('fasting_sugar', 115.0);

-- DEMO 6: Test fn_get_user_health_summary (JSONB response)
SELECT fn_get_user_health_summary((SELECT id FROM users WHERE email = 'raj.kumar@example.com'));

-- DEMO 7: Test pkg_health_analytics.calculate_risk_score
SELECT * FROM pkg_health_analytics.calculate_risk_score((SELECT id FROM users WHERE email = 'raj.kumar@example.com'));

-- DEMO 8: Test pkg_health_analytics.get_bp_trend
SELECT * FROM pkg_health_analytics.get_bp_trend((SELECT id FROM users WHERE email = 'raj.kumar@example.com'), 7);

-- DEMO 9: Test Audit Trail Trigger
DO $$
DECLARE v_rec UUID; v_usr UUID;
BEGIN
    SELECT id INTO v_usr FROM users WHERE email = 'raj.kumar@example.com';
    -- Get last record to update
    SELECT id INTO v_rec FROM health_records WHERE user_id = v_usr AND blood_pressure_systolic = 138;
    
    -- Update it
    UPDATE health_records SET blood_pressure_systolic = 139 WHERE id = v_rec;
END $$;
-- Check Audit tracking
SELECT action_type, new_data->>'blood_pressure_systolic' as updated_sys
FROM health_records_audit 
WHERE changed_by = 'system' ORDER BY changed_at DESC LIMIT 1;


-- DEMO 10: Test BP Validation Trigger (Blocks invalid insertion)
-- DO block cannot catch and return table easy, so we do an intentional failure?
-- No, we just select that it doesn't exist yet, we will capture the exception in Python runner.
-- Will be handled by python block 10


-- DEMO 11: Test Daily Step Goal Trigger
DO $$
DECLARE v_usr UUID;
BEGIN
    SELECT id INTO v_usr FROM users WHERE email = 'raj.kumar@example.com';
    -- He has 4000 steps today, update to 11000
    UPDATE daily_steps SET steps_count = 11000 WHERE user_id = v_usr AND log_date = CURRENT_DATE;
END $$;
-- Verify message was inserted
SELECT user_message, ai_response FROM chat_history WHERE user_id = (SELECT id FROM users WHERE email = 'raj.kumar@example.com') AND user_message = 'System Update: Goal Reached';


-- DEMO 12: Test Cursor-based Subscription Expiry Report
SELECT * FROM fn_subscription_expiry_report();

-- DEMO 13: Test Cursor-based Health Anomalies Scan
SELECT r_metric, r_value FROM fn_scan_health_anomalies(7);

-- DEMO 14: CTE with Window Functions (Moving Average)
WITH daily_bp AS (
    SELECT DATE(recorded_at) as log_date, AVG(blood_pressure_systolic) as avg_sys
    FROM health_records
    WHERE record_type = 'vitals' AND blood_pressure_systolic IS NOT NULL
    GROUP BY DATE(recorded_at)
)
SELECT log_date, ROUND(avg_sys, 2) as current, 
       ROUND(AVG(avg_sys) OVER (ORDER BY log_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) as moving_avg_3d
FROM daily_bp;


-- DEMO 15: Window Functions (Ranking users by tokens used)
SELECT u.first_name, SUM(ch.tokens_used) as total_tokens,
       RANK() OVER (ORDER BY SUM(ch.tokens_used) DESC),
       NTILE(2) OVER (ORDER BY SUM(ch.tokens_used) DESC) as group_no
FROM users u
JOIN chat_history ch ON u.id = ch.user_id
GROUP BY u.first_name;

-- DEMO 16: Test vw_user_health_summary View
SELECT * FROM vw_user_health_summary;

-- DEMO 17: Test Materialized View Refresh
REFRESH MATERIALIZED VIEW mv_platform_daily_stats;
SELECT * FROM mv_platform_daily_stats;

-- DEMO 18: Test Row-Level Security
-- Will be executed in Python with SET app.current_user_id

-- DEMO 19: Test sp_check_subscription_status
-- Amit Patel was setup with an expired premium subscription.
CALL sp_check_subscription_status();
SELECT u.first_name, s.plan_type, s.billing_status 
FROM users u JOIN subscriptions s ON u.id = s.user_id 
WHERE u.email = 'amit.patel@example.com';


-- DEMO 20: Test Soft Delete / DPDP Compliance
DO $$
DECLARE v_usr UUID;
BEGIN
    SELECT id INTO v_usr FROM users WHERE email = 'amit.patel@example.com';
    PERFORM pkg_user_management.soft_delete_user(v_usr);
END $$;
-- Should show redacted data
SELECT email, first_name, is_active FROM users WHERE email LIKE 'deleted_%';
