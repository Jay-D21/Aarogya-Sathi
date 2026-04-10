-- 06_views_indexes_rls.sql
-- Views, Advanced Indexes, and Row Level Security for Aarogya Sathi

-- 1. Regular Views
CREATE OR REPLACE VIEW vw_user_health_summary AS
SELECT 
    u.id as user_id,
    u.first_name,
    u.last_name,
    (SELECT blood_pressure_systolic FROM health_records h WHERE h.user_id = u.id AND blood_pressure_systolic IS NOT NULL ORDER BY recorded_at DESC LIMIT 1) as latest_sys_bp,
    (SELECT blood_pressure_diastolic FROM health_records h WHERE h.user_id = u.id AND blood_pressure_diastolic IS NOT NULL ORDER BY recorded_at DESC LIMIT 1) as latest_dia_bp,
    (SELECT blood_sugar_random FROM health_records h WHERE h.user_id = u.id AND blood_sugar_random IS NOT NULL ORDER BY recorded_at DESC LIMIT 1) as latest_sugar,
    (SELECT COUNT(*) FROM health_conditions hc WHERE hc.user_id = u.id AND condition_status = 'active') as active_conditions_count
FROM users u
WHERE u.is_active = TRUE;


CREATE OR REPLACE VIEW vw_active_users_30d AS
SELECT 
    u.id, u.email, u.first_name, u.last_name, u.last_login_at
FROM users u
WHERE u.is_active = TRUE AND u.last_login_at >= CURRENT_DATE - 30;

-- 2. Materialized Views
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_platform_daily_stats AS
SELECT 
    DATE(ch.created_at) as stat_date,
    COUNT(DISTINCT ch.user_id) as active_chatters,
    COUNT(*) as total_chats,
    SUM(ch.tokens_used) as total_tokens,
    AVG(ch.response_time_ms) as avg_latency_ms
FROM chat_history ch
GROUP BY DATE(ch.created_at)
ORDER BY stat_date DESC;

CREATE UNIQUE INDEX idx_mv_platform_daily_stats_date ON mv_platform_daily_stats(stat_date);

-- 3. Advanced Indexes
-- B-Tree instances are mostly covered by PKs, adding some specific ones
CREATE INDEX IF NOT EXISTS idx_hr_user_recorded ON health_records(user_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_history_user_created ON chat_history(user_id, created_at DESC);

-- GIN (JSONB)
CREATE INDEX IF NOT EXISTS idx_gin_hr_env_ctx ON health_records USING GIN (environmental_context);
CREATE INDEX IF NOT EXISTS idx_gin_mr_biomarkers ON medical_reports USING GIN (biomarkers);

-- Full-Text
CREATE INDEX IF NOT EXISTS idx_fts_chat_msg ON chat_history USING GIN (to_tsvector('english', user_message));

-- Partial
CREATE INDEX IF NOT EXISTS idx_users_active_partial ON users(email) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_alerts_critical_partial ON environmental_alerts(alert_severity) WHERE alert_severity = 'critical';

-- Covering Index
CREATE INDEX IF NOT EXISTS idx_covering_hr_vitals ON health_records (user_id, recorded_at) 
INCLUDE (blood_pressure_systolic, blood_pressure_diastolic, blood_sugar_random);

-- 4. Row Level Security (RLS) setup
ALTER TABLE health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_reports ENABLE ROW LEVEL SECURITY;

-- Create policies. These require a session variable `app.current_user_id` to be set by the backend.
CREATE POLICY p_hr_user_isolation 
ON health_records FOR ALL 
USING (user_id::text = current_setting('app.current_user_id', true));

CREATE POLICY p_chat_user_isolation 
ON chat_history FOR ALL 
USING (user_id::text = current_setting('app.current_user_id', true));

CREATE POLICY p_mr_user_isolation 
ON medical_reports FOR ALL 
USING (user_id::text = current_setting('app.current_user_id', true));

-- Setting force enable allows even table owners to be subject to RLS, useful for testing
-- ALTER TABLE health_records FORCE ROW LEVEL SECURITY;

-- Note on Partitioning: 
-- In PostgreSQL, partitioning must be defined at table creation. 
-- Since we already created chat_history and api_usage without partitioning for simplicity 
-- in the MVP scale, we will skip range partitioning in this file to avoid complex dropping/recreating.
-- However, we provide the conceptual implementation below if we ever wanted to partition it:
/*
-- Example of partitioning setup:
CREATE TABLE chat_history_partitioned (
  -- columns
) PARTITION BY RANGE (created_at);

CREATE TABLE chat_history_2026_01 PARTITION OF chat_history_partitioned
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
*/
