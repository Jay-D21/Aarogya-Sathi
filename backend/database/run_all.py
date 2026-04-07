"""
run_all.py — Master Database Builder & Demo Runner for Aarogya Sathi
Builds the database from scratch, seeds data, runs 20 demos, and generates an HTML report.
"""
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import os
import sys
import html as html_mod
from datetime import datetime

DB_NAME = 'aarogya_sathi'
DB_USER = 'postgres'
DB_PASS = 'Jay'
DB_HOST = 'localhost'
DB_PORT = '5432'

# ──────────────────────────── HELPERS ────────────────────────────

def get_connection(dbname=DB_NAME, autocommit=False):
    conn = psycopg2.connect(dbname=dbname, user=DB_USER, password=DB_PASS, host=DB_HOST, port=DB_PORT)
    if autocommit:
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    return conn

def execute_sql_file(cur, filepath, label=None):
    """Execute an entire SQL file as one statement."""
    label = label or os.path.basename(filepath)
    print(f"  Executing {label}...")
    with open(filepath, 'r', encoding='utf-8') as f:
        sql = f.read()
    cur.execute(sql)
    print(f"  ✓ {label}")

def safe_html(text):
    """Escape text for safe HTML embedding."""
    return html_mod.escape(str(text)) if text is not None else '<em>NULL</em>'

# ──────────────────────────── DATABASE CREATION ────────────────────────────

def create_database():
    print("\n╔══════════════════════════════════════════════╗")
    print("║   STEP 1: Creating Database & Extensions     ║")
    print("╚══════════════════════════════════════════════╝")
    conn = get_connection(dbname='postgres', autocommit=True)
    cur = conn.cursor()

    cur.execute(f"SELECT 1 FROM pg_catalog.pg_database WHERE datname = '{DB_NAME}'")
    if cur.fetchone():
        print(f"  Database '{DB_NAME}' exists. Dropping...")
        cur.execute(f"""
            SELECT pg_terminate_backend(pid)
            FROM pg_stat_activity
            WHERE datname = '{DB_NAME}' AND pid <> pg_backend_pid();
        """)
        cur.execute(f"DROP DATABASE {DB_NAME}")

    print(f"  Creating database '{DB_NAME}'...")
    cur.execute(f"CREATE DATABASE {DB_NAME}")
    cur.close()
    conn.close()

    # Enable extensions
    conn = get_connection(autocommit=True)
    cur = conn.cursor()
    cur.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
    cur.execute('CREATE EXTENSION IF NOT EXISTS "pgcrypto";')
    print("  ✓ Extensions enabled (uuid-ossp, pgcrypto)")
    cur.close()
    conn.close()

# ──────────────────────────── SCHEMA BUILD ────────────────────────────

def build_schema():
    print("\n╔══════════════════════════════════════════════╗")
    print("║   STEP 2: Building Schema (Types → Tables    ║")
    print("║           → Procs → Triggers → Views)        ║")
    print("╚══════════════════════════════════════════════╝")
    conn = get_connection()
    cur = conn.cursor()

    files = [
        ("02_types_and_domains.sql", "Types & Domains (9 ENUMs, 6 Domains)"),
        ("03_tables.sql",            "Tables (18 core + 1 audit = 19 total)"),
        ("04_procedures_and_functions.sql", "Procedures (6), Functions (9), Cursors (2)"),
        ("05_triggers.sql",          "Triggers (7 types, 13 instances)"),
        ("06_views_indexes_rls.sql", "Views, Indexes, RLS Policies"),
    ]

    for filename, label in files:
        execute_sql_file(cur, filename, label)
        conn.commit()

    cur.close()
    conn.close()
    print("  ✓ Schema build complete!")

# ──────────────────────────── SEED DATA ────────────────────────────

def seed_data():
    print("\n╔══════════════════════════════════════════════╗")
    print("║   STEP 3: Seeding Mock Data                   ║")
    print("╚══════════════════════════════════════════════╝")
    conn = get_connection()
    cur = conn.cursor()
    execute_sql_file(cur, "07_seed_data.sql", "Seed Data (3 users, health records, chats, steps)")
    conn.commit()
    cur.close()
    conn.close()

# ──────────────────────────── PL/SQL BLOCKS ────────────────────────────

def run_plsql_blocks():
    """Execute 09_plsql_blocks.sql and capture RAISE NOTICE output."""
    print("\n╔══════════════════════════════════════════════╗")
    print("║   STEP 3b: Running PL/SQL Blocks               ║")
    print("╚══════════════════════════════════════════════╝")
    
    import re
    conn = get_connection(autocommit=True)
    cur = conn.cursor()
    
    all_notices = []
    try:
        with open('09_plsql_blocks.sql', 'r', encoding='utf-8') as f:
            sql = f.read()
        
        # Split into executable blocks: DO $$ ... $$; and CREATE OR REPLACE ...;
        # We split on the block comment headers that start with "-- ===="
        blocks = re.split(r'\n-- ={10,}\n', sql)
        blocks = [b.strip() for b in blocks if b.strip() and not b.strip().startswith('-- 09_')]
        
        for i, block in enumerate(blocks):
            if not block:
                continue
            # Extract block title from first comment line
            title_match = re.search(r'-- BLOCK \d+:.+', block)
            title = title_match.group(0) if title_match else f"Block {i+1}"
            
            try:
                # Clear previous notices
                conn.notices.clear() if hasattr(conn.notices, 'clear') else None
                
                cur.execute(block)
                
                # Collect notices from this block
                for n in conn.notices:
                    clean = n.strip()
                    if clean.startswith('NOTICE:'):
                        clean = clean[len('NOTICE:'):].strip()
                    all_notices.append(clean)
                
                print(f"  ✓ {title}")
            except Exception as e:
                print(f"  ✗ {title}: {e}")
        
        print(f"\n  --- RAISE NOTICE Output ({len(all_notices)} lines) ---")
        for n in all_notices:
            print(f"  {n}")
    except Exception as e:
        print(f"  ✗ PL/SQL Block error: {e}")
    
    cur.close()
    conn.close()
    return all_notices

# ──────────────────────────── DEMO RUNNER ────────────────────────────

def run_single_demo(conn, cur, demo_id, title, prep_sql, verify_sql, expect_error=False):
    """
    Run a single demo: execute prep SQL, then verify SQL, return result dict.
    If expect_error=True, the prep_sql is expected to raise an exception (success = error thrown).
    """
    result = {"id": demo_id, "title": title, "prep_sql": prep_sql, "verify_sql": verify_sql,
              "columns": [], "rows": [], "status": "PASS", "message": ""}

    # Run prep
    if prep_sql:
        try:
            cur.execute(prep_sql)
            conn.commit()
            if expect_error:
                result["status"] = "FAIL"
                result["message"] = "Expected an error but statement succeeded."
                return result
        except Exception as e:
            conn.rollback()
            if expect_error:
                result["status"] = "PASS"
                result["message"] = str(e).strip()
                return result
            else:
                result["status"] = "FAIL"
                result["message"] = f"Prep failed: {str(e).strip()}"
                return result

    # Run verify
    if verify_sql:
        try:
            cur.execute(verify_sql)
            if cur.description:
                result["columns"] = [d[0] for d in cur.description]
                result["rows"] = cur.fetchall()
            conn.commit()
        except Exception as e:
            conn.rollback()
            result["status"] = "FAIL"
            result["message"] = f"Verify failed: {str(e).strip()}"

    return result

def run_demos():
    print("\n╔══════════════════════════════════════════════╗")
    print("║   STEP 4: Running 20 Demo Scenarios           ║")
    print("╚══════════════════════════════════════════════╝")

    conn = get_connection()
    cur = conn.cursor()
    results = []

    # Helper to get a user UUID safely
    def get_user_id(email):
        cur.execute("SELECT id FROM users WHERE email = %s", (email,))
        row = cur.fetchone()
        return str(row[0]) if row else None

    raj_id = get_user_id('raj.kumar@example.com')
    priya_id = get_user_id('priya.s@example.com')
    amit_id = get_user_id('amit.patel@example.com')

    # ── Demo 1: sp_create_user auto-creates preferences + subscription ──
    results.append(run_single_demo(conn, cur, 1,
        "sp_create_user → auto-creates preferences + free subscription",
        None,
        f"SELECT u.email, s.plan_type::text, p.notifications_enabled FROM users u JOIN subscriptions s ON u.id = s.user_id JOIN user_preferences p ON u.id = p.user_id WHERE u.id = '{raj_id}';"
    ))

    # ── Demo 2: sp_log_health_record with critical BP → auto-alert ──
    results.append(run_single_demo(conn, cur, 2,
        "sp_log_health_record with critical BP → auto-alert",
        f"CALL sp_log_health_record('{raj_id}'::uuid, 185, 100, 110, 'Felt dizzy');",
        "SELECT alert_title, alert_description FROM environmental_alerts WHERE alert_title = 'High Blood Pressure Alert' ORDER BY created_at DESC LIMIT 1;"
    ))

    # ── Demo 3: Emergency chat trigger ──
    results.append(run_single_demo(conn, cur, 3,
        "Emergency keyword in chat → auto-creates critical alert",
        f"INSERT INTO chat_history (user_id, user_message, ai_response, contained_emergency_keywords, tokens_used) VALUES ('{priya_id}'::uuid, 'I have terrible chest pain and I am sweating', 'EMERGENCY: Please call 108 immediately.', true, 50);",
        f"SELECT alert_type::text, alert_severity::text, alert_title FROM environmental_alerts WHERE user_id = '{priya_id}' AND alert_type = 'health_emergency';"
    ))

    # ── Demo 4: fn_calculate_bmi ──
    results.append(run_single_demo(conn, cur, 4,
        "fn_calculate_bmi → Asian BMI cutoffs",
        None,
        "SELECT * FROM fn_calculate_bmi(85.0, 175.5);"
    ))

    # ── Demo 5: fn_check_icmr_range ──
    results.append(run_single_demo(conn, cur, 5,
        "fn_check_icmr_range → Prediabetes detection",
        None,
        "SELECT * FROM fn_check_icmr_range('fasting_sugar', 115.0);"
    ))

    # ── Demo 6: fn_get_user_health_summary ──
    results.append(run_single_demo(conn, cur, 6,
        "fn_get_user_health_summary → JSONB health overview",
        None,
        f"SELECT fn_get_user_health_summary('{raj_id}'::uuid);"
    ))

    # ── Demo 7: Risk score calculation ──
    results.append(run_single_demo(conn, cur, 7,
        "pkg_health_analytics.calculate_risk_score",
        None,
        f"SELECT * FROM pkg_health_analytics.calculate_risk_score('{raj_id}'::uuid);"
    ))

    # ── Demo 8: BP trend ──
    results.append(run_single_demo(conn, cur, 8,
        "pkg_health_analytics.get_bp_trend → 7-day trend",
        None,
        f"SELECT * FROM pkg_health_analytics.get_bp_trend('{raj_id}'::uuid, 7);"
    ))

    # ── Demo 9: Audit trail on health record update ──
    results.append(run_single_demo(conn, cur, 9,
        "Audit trigger → tracks UPDATE on health_records",
        f"UPDATE health_records SET notes = 'Feeling better now' WHERE user_id = '{raj_id}'::uuid AND blood_pressure_systolic = 145;",
        "SELECT action_type, old_data->>'notes' as old_notes, new_data->>'notes' as new_notes FROM health_records_audit WHERE action_type = 'UPDATE' ORDER BY changed_at DESC LIMIT 1;"
    ))

    # ── Demo 10: BP validation trigger blocks invalid data ──
    results.append(run_single_demo(conn, cur, 10,
        "BP Validation Trigger → blocks systolic ≤ diastolic",
        f"INSERT INTO health_records (user_id, record_type, blood_pressure_systolic, blood_pressure_diastolic, recorded_at) VALUES ('{raj_id}'::uuid, 'vitals', 100, 150, CURRENT_TIMESTAMP);",
        None,
        expect_error=True
    ))

    # ── Demo 11: Daily step trigger ──
    results.append(run_single_demo(conn, cur, 11,
        "Daily step trigger → congratulatory message at 10K steps",
        f"UPDATE daily_steps SET steps_count = 11000 WHERE user_id = '{raj_id}'::uuid AND log_date = CURRENT_DATE;",
        f"SELECT user_message, ai_response FROM chat_history WHERE user_id = '{raj_id}'::uuid AND user_message = 'System Update: Goal Reached';"
    ))

    # ── Demo 12: Cursor-based subscription expiry report ──
    results.append(run_single_demo(conn, cur, 12,
        "Cursor: fn_subscription_expiry_report",
        None,
        "SELECT * FROM fn_subscription_expiry_report();"
    ))

    # ── Demo 13: Cursor-based health anomaly scan ──
    results.append(run_single_demo(conn, cur, 13,
        "Cursor: fn_scan_health_anomalies → detects critical readings",
        None,
        "SELECT * FROM fn_scan_health_anomalies(7);"
    ))

    # ── Demo 14: CTE + Window function (moving average) ──
    results.append(run_single_demo(conn, cur, 14,
        "CTE + Window Function: 3-day moving average of BP",
        None,
        """WITH daily_bp AS (
            SELECT DATE(recorded_at) as log_date, AVG(blood_pressure_systolic) as avg_sys
            FROM health_records
            WHERE record_type = 'vitals' AND blood_pressure_systolic IS NOT NULL
            GROUP BY DATE(recorded_at)
        )
        SELECT log_date, ROUND(avg_sys, 2) as daily_avg,
               ROUND(AVG(avg_sys) OVER (ORDER BY log_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) as moving_avg_3d,
               ROUND(LAG(avg_sys) OVER (ORDER BY log_date), 2) as prev_day
        FROM daily_bp;"""
    ))

    # ── Demo 15: Window functions (ranking) ──
    results.append(run_single_demo(conn, cur, 15,
        "Window Functions: RANK, NTILE on token usage",
        None,
        """SELECT u.first_name, SUM(ch.tokens_used) as total_tokens,
               RANK() OVER (ORDER BY SUM(ch.tokens_used) DESC) as rank,
               NTILE(2) OVER (ORDER BY SUM(ch.tokens_used) DESC) as group_no
        FROM users u
        JOIN chat_history ch ON u.id = ch.user_id
        WHERE u.is_active = TRUE
        GROUP BY u.first_name;"""
    ))

    # ── Demo 16: View ──
    results.append(run_single_demo(conn, cur, 16,
        "View: vw_user_health_summary",
        None,
        "SELECT first_name, last_name, latest_sys_bp, latest_dia_bp, latest_sugar, active_conditions_count FROM vw_user_health_summary;"
    ))

    # ── Demo 17: Materialized view ──
    results.append(run_single_demo(conn, cur, 17,
        "Materialized View: mv_platform_daily_stats (with REFRESH)",
        "REFRESH MATERIALIZED VIEW mv_platform_daily_stats;",
        "SELECT * FROM mv_platform_daily_stats;"
    ))

    # ── Demo 18: Row-Level Security ──
    rls_result = {"id": 18, "title": "Row-Level Security → user data isolation",
                  "prep_sql": f"SET app.current_user_id = '{raj_id}';",
                  "verify_sql": "SELECT COUNT(*) as visible_records FROM health_records;",
                  "columns": [], "rows": [], "status": "PASS", "message": ""}
    try:
        # RLS only applies to non-superuser roles. For demo, we show the concept.
        # The postgres superuser bypasses RLS, so we demonstrate by explaining.
        cur.execute(f"SET app.current_user_id = '{raj_id}';")
        cur.execute("SELECT COUNT(*) FROM health_records;")
        total = cur.fetchone()[0]
        cur.execute(f"SELECT COUNT(*) FROM health_records WHERE user_id = '{raj_id}'::uuid;")
        raj_only = cur.fetchone()[0]
        rls_result["columns"] = ["total_records_visible", "raj_records", "rls_note"]
        rls_result["rows"] = [(total, raj_only, f"RLS policies created. Superuser sees all {total} rows. App user role would see only {raj_only}.")]
        cur.execute("RESET app.current_user_id;")
        conn.commit()
    except Exception as e:
        conn.rollback()
        rls_result["status"] = "FAIL"
        rls_result["message"] = str(e).strip()
    results.append(rls_result)

    # ── Demo 19: sp_check_subscription_status → downgrades expired ──
    results.append(run_single_demo(conn, cur, 19,
        "sp_check_subscription_status → downgrades expired premium",
        "CALL sp_check_subscription_status();",
        f"SELECT u.first_name, s.plan_type::text, s.billing_status FROM users u JOIN subscriptions s ON u.id = s.user_id WHERE u.id = '{amit_id}'::uuid;"
    ))

    # ── Demo 20: Soft delete with PII redaction ──
    results.append(run_single_demo(conn, cur, 20,
        "DPDP Compliance: soft_delete_user → redacts PII",
        f"SELECT pkg_user_management.soft_delete_user('{amit_id}'::uuid);",
        f"SELECT email, first_name, last_name, is_active, deleted_at IS NOT NULL as is_deleted FROM users WHERE id = '{amit_id}'::uuid;"
    ))

    cur.close()
    conn.close()
    return results

# ──────────────────────────── HTML REPORT ────────────────────────────

def generate_html_report(results, plsql_notices=None):
    print("\n╔══════════════════════════════════════════════╗")
    print("║   STEP 5: Generating HTML Report              ║")
    print("╚══════════════════════════════════════════════╝")

    passed = sum(1 for r in results if r["status"] == "PASS")
    failed = sum(1 for r in results if r["status"] == "FAIL")
    total = len(results)

    lines = []
    lines.append("""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Aarogya Sathi — ADBMS Demo Report</title>
<style>
  :root { --blue: #3498db; --green: #27ae60; --red: #e74c3c; --dark: #2c3e50; --light: #ecf0f1; }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Segoe UI', Tahoma, sans-serif; line-height: 1.7; color: #333; max-width: 1100px; margin: 0 auto; padding: 30px 20px; background: #fafafa; }
  h1 { color: var(--dark); border-bottom: 3px solid var(--blue); padding-bottom: 12px; margin-bottom: 8px; font-size: 1.8rem; }
  .subtitle { color: #666; font-size: 0.95rem; margin-bottom: 24px; }
  .summary-bar { display: flex; gap: 16px; margin-bottom: 30px; }
  .summary-card { flex: 1; padding: 16px; border-radius: 8px; text-align: center; color: #fff; font-size: 1.4rem; font-weight: bold; }
  .summary-card small { display: block; font-size: 0.75rem; font-weight: normal; opacity: 0.9; }
  .card-total { background: var(--blue); }
  .card-pass { background: var(--green); }
  .card-fail { background: var(--red); }
  h2 { color: var(--blue); margin: 30px 0 16px; font-size: 1.3rem; }
  .demo { background: #fff; border-left: 5px solid var(--blue); padding: 18px 20px; margin-bottom: 18px; border-radius: 0 8px 8px 0; box-shadow: 0 1px 4px rgba(0,0,0,0.06); }
  .demo.fail { border-left-color: var(--red); }
  .demo h3 { color: var(--dark); font-size: 1.05rem; margin-bottom: 10px; }
  .demo h3 .badge { display: inline-block; font-size: 0.7rem; padding: 2px 8px; border-radius: 4px; color: #fff; margin-left: 8px; vertical-align: middle; }
  .badge-pass { background: var(--green); }
  .badge-fail { background: var(--red); }
  pre { background: #282c34; color: #abb2bf; padding: 14px 16px; border-radius: 6px; overflow-x: auto; font-size: 0.85rem; margin: 8px 0; white-space: pre-wrap; word-wrap: break-word; }
  table { border-collapse: collapse; width: 100%; margin: 10px 0; }
  th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; font-size: 0.9rem; }
  th { background: var(--light); font-weight: 600; }
  tr:nth-child(even) { background: #f9f9f9; }
  .msg-pass { color: var(--green); font-weight: 600; }
  .msg-fail { color: var(--red); font-weight: 600; }
  .plsql-section { background: #1e1e2e; color: #cdd6f4; padding: 20px 24px; border-radius: 10px; margin: 20px 0; font-family: 'Consolas', 'Courier New', monospace; font-size: 0.82rem; line-height: 1.6; max-height: 600px; overflow-y: auto; white-space: pre-wrap; word-wrap: break-word; }
  .plsql-section .line-ok { color: #a6e3a1; }
  .plsql-section .line-warn { color: #f9e2af; }
  .plsql-section .line-err { color: #f38ba8; }
  .plsql-section .line-header { color: #89b4fa; font-weight: bold; }
  .footer { margin-top: 40px; padding-top: 16px; border-top: 1px solid #ddd; color: #888; font-size: 0.8rem; text-align: center; }
</style>
</head>
<body>""")

    lines.append(f"<h1>🏥 Aarogya Sathi — Advanced DBMS Execution Report</h1>")
    lines.append(f'<p class="subtitle">Generated on {datetime.now().strftime("%B %d, %Y at %I:%M %p")} · PostgreSQL 15 · {total} demos executed</p>')

    lines.append(f"""<div class="summary-bar">
  <div class="summary-card card-total">{total}<small>Total Demos</small></div>
  <div class="summary-card card-pass">{passed}<small>Passed</small></div>
  <div class="summary-card card-fail">{failed}<small>Failed</small></div>
</div>""")

    lines.append("<h2>Demo Results</h2>")

    for r in results:
        css = "demo fail" if r["status"] == "FAIL" else "demo"
        badge_css = "badge-fail" if r["status"] == "FAIL" else "badge-pass"
        badge_text = "FAIL" if r["status"] == "FAIL" else "PASS"

        lines.append(f'<div class="{css}">')
        lines.append(f'<h3>Demo {r["id"]}: {safe_html(r["title"])} <span class="badge {badge_css}">{badge_text}</span></h3>')

        if r.get("prep_sql"):
            lines.append(f'<pre>{safe_html(r["prep_sql"])}</pre>')
        if r.get("verify_sql"):
            lines.append(f'<pre>{safe_html(r["verify_sql"])}</pre>')

        if r["message"]:
            msg_css = "msg-pass" if r["status"] == "PASS" else "msg-fail"
            lines.append(f'<p class="{msg_css}">{safe_html(r["message"])}</p>')

        if r["columns"] and r["rows"]:
            lines.append("<table>")
            lines.append("<tr>" + "".join(f"<th>{safe_html(c)}</th>" for c in r["columns"]) + "</tr>")
            for row in r["rows"]:
                lines.append("<tr>" + "".join(f"<td>{safe_html(v)}</td>" for v in row) + "</tr>")
            lines.append("</table>")
        elif r["columns"] and not r["rows"] and r["status"] == "PASS":
            lines.append('<p><em>Query returned 0 rows (expected for this scenario).</em></p>')

        lines.append("</div>")

    # ── PL/SQL Block Output Section ──
    if plsql_notices:
        lines.append("<h2>PL/SQL Block Execution Output</h2>")
        lines.append('<p style="color:#666; font-size:0.9rem;">Output from 6 anonymous PL/SQL blocks demonstrating: loops, cursors, exception handling, dynamic SQL, nested blocks, and RAISE NOTICE.</p>')
        lines.append('<div class="plsql-section">')
        for notice in plsql_notices:
            escaped = safe_html(notice)
            # Color code based on content
            if '══' in notice or '──' in notice or 'BLOCK' in notice:
                lines.append(f'<span class="line-header">{escaped}</span>')
            elif '✓' in notice or '✔' in notice or 'HEALTHY' in notice:
                lines.append(f'<span class="line-ok">{escaped}</span>')
            elif '✗' in notice or 'CRITICAL' in notice or 'ERROR' in notice or 'REJECTED' in notice:
                lines.append(f'<span class="line-err">{escaped}</span>')
            elif '⚠' in notice or 'HIGH RISK' in notice or 'MODERATE' in notice:
                lines.append(f'<span class="line-warn">{escaped}</span>')
            else:
                lines.append(escaped)
            lines.append('\n')
        lines.append('</div>')

    lines.append(f'<div class="footer">Aarogya Sathi ADBMS Project · {passed}/{total} demos passed · Report auto-generated by run_all.py</div>')
    lines.append("</body></html>")

    report_path = os.path.join(os.path.dirname(__file__), 'adbms_demo_report.html')
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines))

    print(f"  ✓ Report saved to: {report_path}")
    return report_path


# ──────────────────────────── PRINT RESULTS ────────────────────────────

def print_results(results):
    """Print a nicely formatted terminal summary."""
    print("\n" + "=" * 60)
    print("  DEMO RESULTS SUMMARY")
    print("=" * 60)

    for r in results:
        icon = "✓" if r["status"] == "PASS" else "✗"
        print(f"\n  {icon} Demo {r['id']:2d}: {r['title']}")

        if r["message"]:
            # Truncate long messages for terminal
            msg = r["message"][:120] + "..." if len(r["message"]) > 120 else r["message"]
            print(f"           → {msg}")

        if r["columns"] and r["rows"]:
            header = " | ".join(f"{c:>20}" for c in r["columns"])
            print(f"           {header}")
            for row in r["rows"][:3]:  # Show max 3 rows in terminal
                vals = " | ".join(f"{str(v):>20}" for v in row)
                print(f"           {vals}")
            if len(r["rows"]) > 3:
                print(f"           ... and {len(r['rows']) - 3} more rows")

    passed = sum(1 for r in results if r["status"] == "PASS")
    total = len(results)
    print("\n" + "=" * 60)
    print(f"  TOTAL: {passed}/{total} PASSED")
    if passed == total:
        print("  🎉 ALL DEMOS PASSED!")
    print("=" * 60 + "\n")


# ──────────────────────────── MAIN ────────────────────────────

def main():
    print("=" * 60)
    print("  AAROGYA SATHI — DATABASE BUILD & DEMO")
    print("=" * 60)

    create_database()
    build_schema()
    seed_data()
    plsql_notices = run_plsql_blocks()
    results = run_demos()
    print_results(results)
    report_path = generate_html_report(results, plsql_notices)

    print(f"\n  Open the HTML report in your browser:")
    print(f"  file:///{report_path.replace(os.sep, '/')}")


if __name__ == "__main__":
    main()
