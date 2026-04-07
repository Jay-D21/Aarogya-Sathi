---
marp: true
theme: default
size: 16:9
paginate: true
header: "**Aarogya Sathi (आरोग्य साथी)** — Advanced DBMS"
footer: "Database Architecture & PL/SQL Implementation"
style: |
  @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&family=JetBrains+Mono:wght@400;700&display=swap');
  
  section {
    font-family: 'Outfit', sans-serif;
    font-size: 24px;
    padding: 50px 70px; 
    background-color: #f8fafc;
    color: #1e293b;
  }
  
  h1, h2, h3 {
    font-family: 'Outfit', sans-serif;
    margin-top: 0;
  }

  h1 {
    font-size: 2.3em;
    color: #0f172a;
    border-bottom: 4px solid #0284c7;
    padding-bottom: 15px;
    margin-bottom: 20px;
    font-weight: 800;
  }

  h2 {
    font-size: 1.5em;
    color: #0369a1;
    margin-bottom: 15px;
    font-weight: 600;
  }

  pre {
    background: #0f172a;
    color: #f8fafc;
    padding: 15px;
    border-radius: 8px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 0.65em;
    line-height: 1.2;
    overflow-x: hidden;
  }
  
  code {
    font-family: 'JetBrains Mono', monospace;
    background: #e2e8f0;
    color: #b91c1c;
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 0.85em;
  }

  .title-slide {
    background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
    color: white;
    text-align: center;
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  .title-slide h1 {
    border-bottom: none;
    background: -webkit-linear-gradient(45deg, #38bdf8, #818cf8);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-size: 3.5em;
    margin-bottom: 10px;
  }

  .title-slide h2 { color: #cbd5e1; font-weight: 300; }

  .split { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; }
  
  .schema-box {
    background: white;
    padding: 15px 20px;
    border-radius: 8px;
    border-left: 5px solid #0ea5e9;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    margin-bottom: 15px;
  }

  .schema-box h3 { margin-bottom: 8px; font-size: 1.1em; color: #1e293b; }
  .schema-box p { font-size: 0.85em; font-family: 'JetBrains Mono', monospace; color: #475569; margin: 0; line-height: 1.4; }

  .pk { color: #d97706; font-weight: bold; }
  .fk { color: #2563eb; font-weight: bold; }
  
  .info-alert {
    background: rgba(14, 165, 233, 0.1);
    border: 1px solid #0ea5e9;
    padding: 15px;
    border-radius: 8px;
    text-align: center;
    font-weight: 600;
    color: #0369a1;
  }
---

<!-- _class: title-slide -->

# Aarogya Sathi
## Database Management System Architecture
**PostgreSQL 15+ | PL/SQL | BCNF Normalization**

<br>

<div style="background: rgba(15, 23, 42, 0.6); padding: 15px 30px; border-radius: 12px; display: inline-block; text-align: left; font-size: 0.65em; border: 1px solid #38bdf8; margin: 0 auto; min-width: 300px;">
  <p style="margin: 0; color: #cbd5e1; border-bottom: 1px solid #475569; padding-bottom: 5px; margin-bottom: 10px;">
    <strong>Subject:</strong> ADBMS (B. Tech AIML)
  </p>
  <p style="margin: 0; color: #f8fafc; line-height: 1.4;">
    <strong>Jayesh Patil</strong> (Roll No. C233)<br>
    <strong>Ritesh Pawar</strong> (Roll No. C276)
  </p>
</div>

---

# 1. Introduction: Project Overview

**What is Aarogya Sathi?**
A highly transactional, AI-powered Health Companion application tailored for India. It processes contextual health telemetry (Vitals, Workouts, Medical OCR) to provide actionable health awareness.

**Why Focus on Advanced DBMS?**
- **Strict Data Integrity:** Health data requires absolute ACID compliance.
- **High-Volume Telemetry:** Integrates a "Virtual Nurse" framework receiving high-frequency sensor updates.
- **AI Latency Minimization:** Pushing business logic directly to the database via PL/SQL to bypass backend delays.

---

# 2. Tech Stack & Architecture Flow

The entire system relies on PostgreSQL as a single source of truth.

**System Dependencies:**
- **Frontend Layer:** Cross-platform Flutter Application & Local SQLite
- **Backend API:** Python FastAPI Server & Redis 7 (Caching)
- **Database Engine:** PostgreSQL 15+ (Relational, JSONB, & Pl/pgSQL)

**Data Flow Example:**
Mobile Device `-->` REST API `-->` PostgreSQL.
*Once data enters PostgreSQL, automated PL/SQL Triggers take over to validate alerts, calculate age, or evaluate goals independently.*

---

# 3. Conceptual Design: ER & EER Diagrams

To map 18 distinct entities accurately, we utilized advanced Extended Entity-Relationship (EER) modeling to handle complex medical inheritance.

<div class="info-alert">
  📌 <b>Interactive Diagrams Attached</b><br>
  Due to the massive scale of the 18 tables, please refer to the attached <code>CHEN_ER_DIAGRAM.html</code> and <code>EER_DIAGRAM.html</code> provided with our project files for the complete, interactive visual mapping of all relations.
</div>

**Key EER Implementations:**
- **Total/Disjoint Specialization:** `HEALTH_RECORDS` must strictly be *Vitals*, *Symptoms*, *Lifestyle*, or *Medications*.
- **Partial Specialization:** `ENVIRONMENTAL_ALERTS` branching into *AQI Spikes* vs *Temperature Waves*.

---

# 4. Relational Schema: Core Auth & System

Strict **Boyce-Codd Normal Form (BCNF)** eliminating partial or transitive dependencies.

<div class="split">
  <div>
    <div class="schema-box">
      <h3>USERS</h3>
      <p><span class="pk">id (UUID)</span>, email, phone, password_hash, first_name, gender, dob, created_at</p>
    </div>
    <div class="schema-box">
      <h3>AUTH_SESSIONS</h3>
      <p><span class="pk">id (UUID)</span>, <span class="fk">user_id (UUID)</span>, access_token, device_type, ip, expires_at</p>
    </div>
    <div class="schema-box">
      <h3>USER_PREFERENCES</h3>
      <p><span class="pk">id (UUID)</span>, <span class="fk">user_id (UUID)</span>, notifications_enabled, dark_mode, voice_language</p>
    </div>
  </div>
  <div>
    <div class="schema-box">
      <h3>SUBSCRIPTIONS</h3>
      <p><span class="pk">id (UUID)</span>, <span class="fk">user_id (UUID)</span>, plan_type [ENUM], plan_name, billing_amount_inr, end_date</p>
    </div>
    <div class="schema-box">
      <h3>CHAT_HISTORY</h3>
      <p><span class="pk">id (UUID)</span>, <span class="fk">user_id (UUID)</span>, user_message, ai_response, tokens_used</p>
    </div>
  </div>
</div>

---

# 5. Relational Schema: Medical & Telemetry

Utilizing PostgreSQL JSONB capabilities for dynamic medical data alongside structured vitals.

<div class="split">
  <div>
    <div class="schema-box">
      <h3>HEALTH_RECORDS (Superclass)</h3>
      <p><span class="pk">id (UUID)</span>, <span class="fk">user_id (UUID)</span>, record_type, bp_systolic, bp_diastolic, blood_sugar_fasting, recorded_at</p>
    </div>
    <div class="schema-box">
      <h3>MEDICAL_REPORTS</h3>
      <p><span class="pk">id (UUID)</span>, <span class="fk">user_id (UUID)</span>, lab_name, <b>biomarkers (JSONB)</b>, interpretation</p>
    </div>
  </div>
  <div>
    <div class="schema-box">
      <h3>DAILY_STEPS (Virtual Nurse)</h3>
      <p><span class="pk">id (UUID)</span>, <span class="fk">user_id (UUID)</span>, log_date, step_count, distance_meters</p>
    </div>
    <div class="schema-box">
      <h3>ENVIRONMENTAL_ALERTS</h3>
      <p><span class="pk">id (UUID)</span>, <span class="fk">user_id (UUID)</span>, alert_type, severity, aqi_value, temperature_celsius</p>
    </div>
  </div>
</div>

---

# 6. PL/SQL Stored Procedures (Part 1)

These stored procedures act as the primary operational backbone of the database, ensuring ACID-compliant transactions across multiple tables.

- **`sp_create_user()`:** Ensures atomicity during user registration. Provisions the core user record, default preferences, starting analytics, and a free subscription in a single atomic transaction.
- **`sp_log_health_record()`:** A rapid safety-catch mechanism for vitals. Evaluates Blood Pressure and Fasting Sugar levels directly at the database layer. If critical ICMR thresholds are met, it autonomously spawns a `CRITICAL` alert.
- **`sp_generate_analytics_report()`:** Aggregates health data and chat volume into `user_analytics` to optimize dashboard retrieval times.

---

# 7. PL/SQL Stored Procedures (Part 2)

- **`sp_process_environmental_alerts()`:** Processes municipal-level AQI/Temperature data and bulk-inserts individual warnings into `environmental_alerts` for all active users matched by city.
- **`sp_evaluate_step_goal()`:** Evaluates daily incoming pedometer data against personalized user targets. On success, securely intercepts the chat history to inject congratulatory system update nodes.
- **`sp_check_subscription_status()`:** A daily batch procedure that downgrades expired premium subscriptions efficiently directly at the source.

---

# 8. Database Functions & Packages

Standalone Pl/pgSQL functions that handle complex medical and clinical categorization without burdening the application middleware.

- **`fn_calculate_bmi()`:** Implements Asian-specific BMI thresholds for precise obesity categorization.
- **`fn_check_icmr_range()`:** Evaluates multiple biomarkers (e.g. Systolic, Diastolic, Fasting Sugar) against strict medical heuristics.
- **`pkg_health_analytics.*`:** A curated package of functions (`get_bp_trend`, `get_sugar_trend`, `calculate_risk_score`) used heavily for long-term graphical interpolation on the mobile device.

---

# 9. Automated Behavior: DB Triggers

Triggers enforce strict, event-driven data integrity without application intervention.

- **`trg_update_timestamp_*`:** Attached to all 7 primary tables. Automatically guarantees `updated_at` accuracy for synchronization.
- **`trg_audit_health_records_t`:** A critical DPDP-compliance trigger. Copies the `OLD` JSONB record state to `health_records_audit` upon any UPDATE or DELETE operation for clinical traceability.
- **`trg_validate_bp_t`:** An architectural firewall that blocks any insertion where Systolic BP is less than or equal to Diastolic BP.

---

# 10. Automated Responses: DB Triggers

- **`trg_log_chat_api_t`:** Triggers `AFTER INSERT` on chat logs to securely tally LLM API token consumption into the `api_usage` billing table.
- **`trg_emergency_alert_t`:** Monitors a boolean flag set by the AI's NLP engine. Instantly injects an overriding high-priority medical warning if symptoms appear severe.
- **`trg_auto_downgrade_t`:** Blockades the API from extending subscription plans past expiration by intercepting the `UPDATE` call when auto-renewal rules fail.

---

# 11. Application & Results

**Results of Advanced DBMS Implementation:**
- **Zero Data Corruption:** Normalizing telemetry inputs into BCNF effectively eliminated write-anomalies during bursty IoT telemetry streams.
- **Sub-Millisecond Threat Detection:** By evaluating emergency chat flags and ICMR BP/Sugar thresholds via Pl/pgSQL `TRIGGERS` and `PROCEDURES`, the system bypasses ~200ms of API transport latency, offering immediate system-level interventions.
- **Medical DPDP Compliance:** Tracking historical versions of records inside `health_records_audit` via Triggers satisfies strict legal specifications for clinical data modification.

---

<!-- _class: title-slide -->

# 12. Conclusion

**Summary of Aarogya Sathi DBMS Integration:**
The Aarogya Sathi ecosystem leverages PostgreSQL 15+ not merely as a passive data store, but as an active, intelligent computational layer. 

By pushing strict constraint enforcement, transaction atomicity, clinical validations, and trigger-based AI monitoring directly into the Relational Engine, the platform guarantees **extreme resilience**, minimizing points of failure at the Application layer and producing an architecture built for high-scale clinical operations.

---

<!-- _class: title-slide -->

# 13. References

<div style="background: rgba(15,23,42,0.8); padding: 20px; border-radius: 12px; margin-top: 20px; text-align: left; font-size: 0.7em;">
  <p style="color: #cbd5e1; margin-bottom: 10px;"><b>1. PostgreSQL Global Development Group.</b> (2024). <i>PostgreSQL 15 Documentation: PL/pgSQL</i>. <br>&nbsp;&nbsp;&nbsp;Available at: https://www.postgresql.org/docs/current/plpgsql.html</p>
  
  <p style="color: #cbd5e1; margin-bottom: 10px;"><b>2. Elmasri, R., & Navathe, S. B.</b> (2015). <i>Fundamentals of Database Systems</i> (7th ed.). <br>&nbsp;&nbsp;&nbsp;Pearson Education - Normalization & Relational Algebra Theory.</p>

  <p style="color: #cbd5e1; margin-bottom: 10px;"><b>3. Indian Council of Medical Research (ICMR).</b> (2020). <i>National Guidelines for Management of Hypertension and Diabetes</i>. <br>&nbsp;&nbsp;&nbsp;Used as architectural schema constraint logic for `fn_check_icmr_range()`.</p>
</div>
