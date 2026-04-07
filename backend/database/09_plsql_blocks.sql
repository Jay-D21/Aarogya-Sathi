-- ============================================================================
-- 09_plsql_blocks.sql
-- Advanced PL/SQL Blocks for Aarogya Sathi
-- Demonstrates: Anonymous blocks, Exception handling, Loops, Cursors,
--               Nested blocks, Savepoints, Dynamic SQL, RAISE NOTICE
-- ============================================================================


-- ============================================================================
-- BLOCK 1: Anonymous Block — Bulk Health Assessment with Exception Handling
-- Demonstrates: DO block, FOR loop, IF/ELSIF, EXCEPTION, RAISE NOTICE
-- ============================================================================

DO $$
DECLARE
    v_user RECORD;
    v_latest_sys INT;
    v_latest_sugar INT;
    v_assessment TEXT;
    v_count INT := 0;
BEGIN
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE 'BLOCK 1: Bulk Health Assessment Report';
    RAISE NOTICE '══════════════════════════════════════════════════';
    
    FOR v_user IN 
        SELECT id, first_name, last_name, email 
        FROM users 
        WHERE is_active = TRUE 
        ORDER BY first_name
    LOOP
        -- Nested BEGIN...EXCEPTION for per-user error isolation
        BEGIN
            -- Fetch latest systolic BP
            SELECT blood_pressure_systolic INTO v_latest_sys
            FROM health_records 
            WHERE user_id = v_user.id AND blood_pressure_systolic IS NOT NULL
            ORDER BY recorded_at DESC LIMIT 1;
            
            -- Fetch latest sugar
            SELECT COALESCE(blood_sugar_fasting, blood_sugar_random) INTO v_latest_sugar
            FROM health_records 
            WHERE user_id = v_user.id 
              AND (blood_sugar_fasting IS NOT NULL OR blood_sugar_random IS NOT NULL)
            ORDER BY recorded_at DESC LIMIT 1;
            
            -- Assess health status
            IF v_latest_sys IS NULL AND v_latest_sugar IS NULL THEN
                v_assessment := 'NO DATA — needs to log vitals';
            ELSIF v_latest_sys > 180 OR COALESCE(v_latest_sugar, 0) > 300 THEN
                v_assessment := '🔴 CRITICAL — immediate attention required';
            ELSIF v_latest_sys > 140 OR COALESCE(v_latest_sugar, 0) > 200 THEN
                v_assessment := '🟡 HIGH RISK — needs monitoring';
            ELSIF v_latest_sys > 120 OR COALESCE(v_latest_sugar, 0) > 140 THEN
                v_assessment := '🟠 MODERATE — borderline values';
            ELSE
                v_assessment := '🟢 HEALTHY — within normal range';
            END IF;
            
            v_count := v_count + 1;
            RAISE NOTICE '  [%] % % — BP: %, Sugar: % → %', 
                v_count, v_user.first_name, COALESCE(v_user.last_name, ''), 
                COALESCE(v_latest_sys::TEXT, 'N/A'),
                COALESCE(v_latest_sugar::TEXT, 'N/A'),
                v_assessment;
                
        EXCEPTION 
            WHEN OTHERS THEN
                RAISE NOTICE '  ⚠ Error processing user %: %', v_user.email, SQLERRM;
        END;  -- End of nested block
    END LOOP;
    
    RAISE NOTICE '──────────────────────────────────────────────────';
    RAISE NOTICE '  Total users assessed: %', v_count;
    RAISE NOTICE '══════════════════════════════════════════════════';
END $$;


-- ============================================================================
-- BLOCK 2: Nested Block with SAVEPOINT — Safe Batch Insert with Rollback
-- Demonstrates: Nested blocks, SAVEPOINT, partial ROLLBACK, WHILE loop
-- ============================================================================

DO $$
DECLARE
    v_user_id UUID;
    v_day INT := 1;
    v_max_days INT := 5;
    v_sys INT;
    v_dia INT;
    v_inserted INT := 0;
    v_skipped INT := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE 'BLOCK 2: Safe Batch Insert with Savepoints';
    RAISE NOTICE '══════════════════════════════════════════════════';
    
    SELECT id INTO v_user_id FROM users WHERE email = 'priya.s@example.com';
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User priya.s@example.com not found!';
    END IF;
    
    WHILE v_day <= v_max_days LOOP
        -- Generate sample BP values (some intentionally invalid)
        v_sys := 110 + (v_day * 5);          -- 115, 120, 125, 130, 135
        v_dia := 80 + (v_day * 3);           -- 83, 86, 89, 92, 95
        
        -- Make day 4 intentionally invalid (systolic < diastolic)
        IF v_day = 4 THEN
            v_sys := 70;
            v_dia := 120;
        END IF;
        
        -- SAVEPOINT so failure doesn't nuke the whole batch
        -- Nested block with its own exception handler
        BEGIN
            INSERT INTO health_records (
                user_id, record_type, 
                blood_pressure_systolic, blood_pressure_diastolic, 
                recorded_at, notes
            ) VALUES (
                v_user_id, 'vitals', v_sys, v_dia, 
                CURRENT_TIMESTAMP - ((v_max_days - v_day) || ' days')::interval,
                'PL/SQL Block 2 — batch insert day ' || v_day
            );
            
            v_inserted := v_inserted + 1;
            RAISE NOTICE '  ✓ Day %: BP %/% inserted successfully', v_day, v_sys, v_dia;
            
        EXCEPTION 
            WHEN raise_exception THEN
                v_skipped := v_skipped + 1;
                RAISE NOTICE '  ✗ Day %: BP %/% REJECTED — % (Savepoint rolled back)', 
                    v_day, v_sys, v_dia, SQLERRM;
            WHEN OTHERS THEN
                v_skipped := v_skipped + 1;
                RAISE NOTICE '  ✗ Day %: Unexpected error — %', v_day, SQLERRM;
        END;
        
        v_day := v_day + 1;
    END LOOP;
    
    RAISE NOTICE '──────────────────────────────────────────────────';
    RAISE NOTICE '  Inserted: %, Skipped: %, Total: %', v_inserted, v_skipped, v_max_days;
    RAISE NOTICE '══════════════════════════════════════════════════';
END $$;


-- ============================================================================
-- BLOCK 3: Explicit Cursor with FETCH — User Risk Report
-- Demonstrates: DECLARE CURSOR, OPEN, FETCH, CLOSE, EXIT WHEN, %FOUND
-- ============================================================================

DO $$
DECLARE
    -- Explicit cursor declaration
    cur_users CURSOR FOR 
        SELECT u.id, u.first_name || ' ' || COALESCE(u.last_name, '') as full_name, 
               u.email, s.plan_type::TEXT
        FROM users u
        JOIN subscriptions s ON u.id = s.user_id
        WHERE u.is_active = TRUE
        ORDER BY u.first_name;
    
    v_rec RECORD;
    v_health_count INT;
    v_risk_score INT;
    v_risk_label TEXT;
    v_total_assessed INT := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE 'BLOCK 3: Explicit Cursor — User Risk Report';
    RAISE NOTICE '══════════════════════════════════════════════════';
    
    OPEN cur_users;
    
    LOOP
        FETCH cur_users INTO v_rec;
        EXIT WHEN NOT FOUND;
        
        -- Count health records for this user
        SELECT COUNT(*) INTO v_health_count 
        FROM health_records WHERE user_id = v_rec.id;
        
        -- Calculate risk score using our package function
        SELECT score INTO v_risk_score 
        FROM pkg_health_analytics.calculate_risk_score(v_rec.id);
        
        CASE 
            WHEN v_risk_score > 50 THEN v_risk_label := '🔴 HIGH';
            WHEN v_risk_score > 20 THEN v_risk_label := '🟡 MODERATE';
            WHEN v_risk_score > 0  THEN v_risk_label := '🟢 LOW';
            ELSE v_risk_label := '⚪ NO DATA';
        END CASE;
        
        v_total_assessed := v_total_assessed + 1;
        RAISE NOTICE '  [%] % (%) | Plan: % | Records: % | Risk: % (%)', 
            v_total_assessed, v_rec.full_name, v_rec.email, 
            UPPER(v_rec.plan_type), v_health_count, v_risk_label, v_risk_score;
    END LOOP;
    
    CLOSE cur_users;
    
    RAISE NOTICE '──────────────────────────────────────────────────';
    RAISE NOTICE '  Cursor closed. % users assessed.', v_total_assessed;
    RAISE NOTICE '══════════════════════════════════════════════════';
END $$;


-- ============================================================================
-- BLOCK 4: Dynamic SQL (EXECUTE) — Flexible Report Generator
-- Demonstrates: EXECUTE ... USING, FORMAT(), dynamic table/column names
-- ============================================================================

DO $$
DECLARE
    v_table_name TEXT;
    v_count BIGINT;
    v_total BIGINT := 0;
    v_tables TEXT[] := ARRAY[
        'users', 'health_records', 'health_records_audit', 'chat_history', 
        'medical_reports', 'environmental_alerts', 'health_conditions',
        'user_preferences', 'auth_sessions', 'abdm_integrations',
        'subscriptions', 'user_analytics', 'api_usage', 'user_feedback',
        'corporate_accounts', 'corporate_employee_mapping',
        'daily_steps', 'workouts', 'reminders'
    ];
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE 'BLOCK 4: Dynamic SQL — Database Census Report';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '  %-35s | %s', 'TABLE NAME', 'ROW COUNT';
    RAISE NOTICE '  %-35s-+-%s', '-----------------------------------', '----------';
    
    FOREACH v_table_name IN ARRAY v_tables LOOP
        -- Dynamic SQL: table names can't be parameterized, so use format()
        EXECUTE format('SELECT COUNT(*) FROM %I', v_table_name) INTO v_count;
        v_total := v_total + v_count;
        
        RAISE NOTICE '  %-35s | %', v_table_name, v_count;
    END LOOP;
    
    RAISE NOTICE '  %-35s-+-%s', '-----------------------------------', '----------';
    RAISE NOTICE '  %-35s | %', 'TOTAL ROWS', v_total;
    RAISE NOTICE '══════════════════════════════════════════════════';
END $$;


-- ============================================================================
-- BLOCK 5: Exception Hierarchy & Custom Exceptions
-- Demonstrates: RAISE EXCEPTION, custom error codes, SQLSTATE, multiple handlers
-- ============================================================================

DO $$
DECLARE
    v_metric TEXT := 'blood_pressure_systolic';
    v_value DECIMAL;
    v_user_id UUID;
    v_user_name TEXT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE 'BLOCK 5: Exception Handling Hierarchy';
    RAISE NOTICE '══════════════════════════════════════════════════';
    
    -- Get first active user
    SELECT id, first_name INTO v_user_id, v_user_name 
    FROM users WHERE is_active = TRUE ORDER BY first_name LIMIT 1;
    
    -- Outer block: validate metric
    IF v_metric NOT IN ('blood_pressure_systolic', 'blood_pressure_diastolic', 
                         'blood_sugar_fasting', 'blood_sugar_random') THEN
        RAISE EXCEPTION 'Invalid metric: %', v_metric USING ERRCODE = 'P0003';
    END IF;
    
    RAISE NOTICE '  Checking metric "%" for user "%"...', v_metric, v_user_name;
    
    -- Fetch latest value using dynamic SQL 
    EXECUTE format(
        'SELECT %I FROM health_records WHERE user_id = $1 AND %I IS NOT NULL ORDER BY recorded_at DESC LIMIT 1',
        v_metric, v_metric
    ) INTO v_value USING v_user_id;
    
    IF v_value IS NULL THEN
        RAISE EXCEPTION 'No data found for metric %', v_metric
            USING ERRCODE = 'P0002'; -- no_data_found
    END IF;
    
    RAISE NOTICE '  Latest value: %', v_value;
    
    -- Check threshold
    IF v_metric = 'blood_pressure_systolic' AND v_value > 180 THEN
        RAISE EXCEPTION 'Threshold exceeded: % = %', v_metric, v_value
            USING ERRCODE = 'P0004';
    END IF;
    
    -- Inner block: attempt to log the check
    BEGIN
        INSERT INTO user_analytics (user_id, date, total_health_records_logged)
        VALUES (v_user_id, CURRENT_DATE, 1)
        ON CONFLICT (user_id, date) DO UPDATE 
        SET total_health_records_logged = user_analytics.total_health_records_logged + 1;
        
        RAISE NOTICE '  ✓ Analytics updated successfully.';
        
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE '  ⚠ Analytics conflict — record already exists.';
    END;
    
    RAISE NOTICE '  ✓ Health check completed without critical issues.';
    
EXCEPTION
    WHEN SQLSTATE 'P0003' THEN  -- Custom: invalid_metric
        RAISE NOTICE '  ✗ ERROR: Invalid metric "%". Supported: bp_systolic, bp_diastolic, sugar_fasting, sugar_random', v_metric;
    WHEN SQLSTATE 'P0004' THEN  -- Custom: threshold_exceeded
        RAISE NOTICE '  ⚠ CRITICAL: % = % exceeds emergency threshold!', v_metric, v_value;
        RAISE NOTICE '  → Auto-generating emergency alert...';
    WHEN SQLSTATE 'P0002' THEN  -- no_data_found
        RAISE NOTICE '  ✗ No data found for metric "%"', v_metric;
    WHEN OTHERS THEN
        RAISE NOTICE '  ✗ Unexpected error [%]: %', SQLSTATE, SQLERRM;
END $$;


-- ============================================================================
-- BLOCK 6: Parameterized Procedure — Subscription Lifecycle Manager
-- Marks: Stored Procedure with Transaction Control, CASE, Nested IF
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_manage_subscription(
    p_user_id UUID,
    p_action VARCHAR,  -- 'upgrade', 'downgrade', 'renew', 'cancel'
    p_plan subscription_plan_type DEFAULT 'premium',
    OUT p_result TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_plan subscription_plan_type;
    v_current_status TEXT;
    v_sub_id UUID;
BEGIN
    -- Fetch current subscription
    SELECT id, plan_type, billing_status INTO v_sub_id, v_current_plan, v_current_status
    FROM subscriptions WHERE user_id = p_user_id
    ORDER BY created_at DESC LIMIT 1;
    
    IF v_sub_id IS NULL THEN
        p_result := 'ERROR: No subscription found for this user.';
        RETURN;
    END IF;
    
    CASE p_action
        WHEN 'upgrade' THEN
            IF v_current_plan = 'premium' THEN
                p_result := 'Already on premium plan. No change.';
            ELSE
                UPDATE subscriptions 
                SET plan_type = p_plan, 
                    plan_name = 'Aarogya Sathi ' || INITCAP(p_plan::TEXT),
                    billing_status = 'active',
                    billing_amount_inr = CASE p_plan 
                        WHEN 'premium' THEN 99.00 
                        WHEN 'corporate' THEN 499.00 
                        ELSE 0.00 
                    END,
                    subscription_start_date = CURRENT_TIMESTAMP,
                    subscription_end_date = CURRENT_TIMESTAMP + INTERVAL '1 year'
                WHERE id = v_sub_id;
                p_result := 'Upgraded to ' || p_plan::TEXT || ' successfully.';
            END IF;
            
        WHEN 'downgrade' THEN
            UPDATE subscriptions 
            SET plan_type = 'free', 
                plan_name = 'Aarogya Sathi Basic',
                billing_status = 'cancelled',
                billing_amount_inr = 0
            WHERE id = v_sub_id;
            p_result := 'Downgraded to free plan.';
            
        WHEN 'renew' THEN
            IF v_current_plan = 'free' THEN
                p_result := 'Cannot renew a free plan. Upgrade first.';
            ELSE
                UPDATE subscriptions 
                SET subscription_end_date = GREATEST(subscription_end_date, CURRENT_TIMESTAMP) + INTERVAL '1 year',
                    billing_status = 'active',
                    next_billing_date = CURRENT_TIMESTAMP + INTERVAL '1 year'
                WHERE id = v_sub_id;
                p_result := 'Renewed ' || v_current_plan::TEXT || ' for 1 year.';
            END IF;
            
        WHEN 'cancel' THEN
            UPDATE subscriptions
            SET billing_status = 'cancelled',
                auto_renewal = FALSE,
                cancellation_date = CURRENT_TIMESTAMP,
                cancellation_reason = 'User-initiated cancellation'
            WHERE id = v_sub_id;
            p_result := 'Subscription cancelled. Active until end date.';
            
        ELSE
            p_result := 'ERROR: Unknown action "' || p_action || '". Use: upgrade, downgrade, renew, cancel.';
    END CASE;
END;
$$;
