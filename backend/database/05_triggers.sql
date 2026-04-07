-- 05_triggers.sql
-- Triggers for Aarogya Sathi

-- 1. Auto-update timestamp function
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all relevant tables (7 instances of this trigger type)
CREATE TRIGGER trg_update_timestamp_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_update_timestamp_health BEFORE UPDATE ON health_records FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_update_timestamp_chat BEFORE UPDATE ON chat_history FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_update_timestamp_reports BEFORE UPDATE ON medical_reports FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_update_timestamp_conditions BEFORE UPDATE ON health_conditions FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_update_timestamp_prefs BEFORE UPDATE ON user_preferences FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();
CREATE TRIGGER trg_update_timestamp_subs BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION fn_update_timestamp();

-- 2. Audit Health Records function
CREATE OR REPLACE FUNCTION fn_audit_health_records()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO health_records_audit (record_id, user_id, action_type, old_data)
        VALUES (OLD.id, OLD.user_id, 'DELETE', to_jsonb(OLD));
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO health_records_audit (record_id, user_id, action_type, old_data, new_data)
        VALUES (NEW.id, NEW.user_id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO health_records_audit (record_id, user_id, action_type, new_data)
        VALUES (NEW.id, NEW.user_id, 'INSERT', to_jsonb(NEW));
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_health_records_t
AFTER INSERT OR UPDATE OR DELETE ON health_records
FOR EACH ROW EXECUTE FUNCTION fn_audit_health_records();

-- 3. Validate BP range function
CREATE OR REPLACE FUNCTION fn_validate_bp()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.blood_pressure_systolic IS NOT NULL AND NEW.blood_pressure_diastolic IS NOT NULL THEN
        IF NEW.blood_pressure_systolic <= NEW.blood_pressure_diastolic THEN
            RAISE EXCEPTION 'Systolic BP must be greater than Diastolic BP';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_bp_t
BEFORE INSERT OR UPDATE ON health_records
FOR EACH ROW EXECUTE FUNCTION fn_validate_bp();

-- 4. Auto-Downgrade Subscription function
CREATE OR REPLACE FUNCTION fn_auto_downgrade()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subscription_end_date < CURRENT_TIMESTAMP AND NEW.auto_renewal = FALSE THEN
        NEW.plan_type = 'free';
        NEW.billing_status = 'cancelled';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_downgrade_t
BEFORE UPDATE ON subscriptions
FOR EACH ROW EXECUTE FUNCTION fn_auto_downgrade();

-- 5. Log Chat API Usage
CREATE OR REPLACE FUNCTION fn_log_chat_api()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO api_usage (
        user_id, endpoint_path, http_method, model_used, 
        input_tokens, output_tokens, total_tokens, estimated_cost_inr
    ) VALUES (
        NEW.user_id, '/api/v1/chat/message', 'POST', NEW.model_used,
        NEW.tokens_used / 2, NEW.tokens_used / 2, NEW.tokens_used, 
        (NEW.tokens_used * 0.0001) -- Rough estimate mapping token count to INR
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_chat_api_t
AFTER INSERT ON chat_history
FOR EACH ROW EXECUTE FUNCTION fn_log_chat_api();

-- 6. Emergency Alert
CREATE OR REPLACE FUNCTION fn_emergency_alert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.contained_emergency_keywords = TRUE THEN
        INSERT INTO environmental_alerts (
            user_id, alert_type, alert_severity, alert_title, alert_description
        ) VALUES (
            NEW.user_id, 'health_emergency', 'critical', 'Potential Medical Emergency',
            'Our system detected emergency language in your recent chat. Please call 108 immediately if you need medical help.'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_emergency_alert_t
AFTER INSERT ON chat_history
FOR EACH ROW EXECUTE FUNCTION fn_emergency_alert();


-- 7. Daily Step Check
CREATE OR REPLACE FUNCTION fn_daily_step_check()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.steps_count >= 10000 AND OLD.steps_count < 10000 THEN
        -- Fire once per day when passing 10k
        -- Call SP for evaluating goal
        CALL sp_evaluate_step_goal(NEW.user_id, NEW.log_date, NEW.steps_count);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_daily_step_check_t
AFTER UPDATE ON daily_steps
FOR EACH ROW EXECUTE FUNCTION fn_daily_step_check();
