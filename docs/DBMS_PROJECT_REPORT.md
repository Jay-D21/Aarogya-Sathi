# Aarogya Sathi: Database Management System (DBMS) Project Report

> **Note to Reviewers:** This document serves as the high-level executive summary of the database architecture. For the complete, unabridged schema including all SQL constraints, Domains, ENUMs, Triggers, Views, Procedures, and Partitioning logic, please refer to the **[Advanced DBMS Documentation](./DATABASE_ADVANCED_DBMS.md)**.

## 1. Project Introduction (DBMS Perspective)
Aarogya Sathi is a comprehensive AI healthcare assistant application. From a database perspective, it is a highly transactional system requiring robust handling of user interactions, health telemetry, and temporal environmental data. 

The primary challenge of this database architecture is securely managing highly normalized medical records alongside unstructured chat interactions, while supporting complex, real-time querying for the AI to provide contextual health advice. The database acts as the single source of truth, managing user state, subscription tiers, and enforcing strict data integrity rules for health data.

Following the recent expansion into a "Virtual Nurse" model, the database also efficiently handles high-frequency lifestyle tracking (daily steps, workouts, medication and hydration reminders).

---

## 2. Conceptual Modeling: ER & EER Diagrams

The conceptual design maps the business logic into distinct entities and their relationships. 

### 2.1 Standard ER Diagram (18 Entities)
* **[View Interactive ER Diagram](./CHEN_ER_DIAGRAM.html)**

The classic Entity-Relationship (ER) diagram visualizes the core 18 independent entities. 
* **Core Entities:** `USERS` sits at the center, interacting with `CHAT_HISTORY`, logging `HEALTH_RECORDS`, and scheduling `REMINDERS`.
* **Virtual Nurse Integrations:** New standalone tracking entities like `DAILY_STEPS` and `WORKOUTS` allow users to passively sync data from phone sensors.
* **Corporate B2B Structure:** `CORPORATE_ACCOUNTS` map to multiple users via the `CORPORATE_EMP_MAP`.

### 2.2 Extended ER (EER) Diagram
* **[View Interactive EER Diagram](./EER_DIAGRAM.html)**

The EER diagram builds upon the ER model by introducing Object-Oriented concepts, specifically **Specialization/Generalization (IS-A relationships)**. This minimizes null values and enforces stricter constraints.
* **Notation:** Dark green circles with 'd' indicate **Disjoint** constraints. '∩' symbols indicate subsets.
* **Total Specialization Examples:**
  * `HEALTH_RECORDS` must be exactly one of: *Vitals, Symptoms, Lifestyle, Medication*.
  * `REMINDERS` must be exactly one of: *Medication, Water, Meal*.
  * `SUBSCRIPTIONS` must be exactly one of: *Free, Premium*.

---

## 3. Relational Schema Summary

The database strictly adheres to **Boyce-Codd Normal Form (BCNF)**. The 18 tables are partitioned into logical domains:

### 3.1 Auth & Users
* **`users`**: Core profile data, authentication keys, derived age.
* **`auth_sessions`**: JWT issuance and device tracking.
* **`user_preferences`**: Granular settings (Notifications, Voice Input).

### 3.2 Medical & Health Telemetry
* **`health_records`**: Superclass table with Single-Table Inheritance for BP, Sugar, BMI, Sleep, and Stress data.
* **`health_conditions`**: Ongoing chronic issues (e.g., Hypertension).
* **`medical_reports`**: Biometric data auto-extracted from PDFs via OCR.

### 3.3 Virtual Nurse Trackers (New)
* **`daily_steps`**: Daily log of pedometer data. Evaluated by backend procedures for goal achievement.
* **`workouts`**: Duration, calories, and exercise typing.
* **`reminders`**: Superclass for active `med_reminders`, `water_reminders`, and `meal_reminders`.

### 3.4 System Logs & AI Context
* **`chat_history`**: Unstructured human-AI interactions + token usage.
* **`environmental_alerts`**: Real-time hyper-local AQI and Temperature hazard warnings.
* **`api_usage`**: Per-request cost tracking for LLM endpoints.

*See [DATABASE_ADVANCED_DBMS.md (Section 3) - Normalization Proof](./DATABASE_ADVANCED_DBMS.md#3-relational-schema--normalization).*

---

## 4. Advanced DBMS Implementation Highlights

To maintain data integrity and automate workflows, Aarogya Sathi bypasses application-level logic when appropriate, leaning into native PostgreSQL features.

### 4.1 Automated Workflows (Triggers)
The system utilizes 13 active triggers. Notable examples include:
* **`trg_calculate_derived_age`**: Automatically computes age on insert/update of DOB.
* **`trg_daily_summary_check`**: Monitors `daily_steps`. Upon crossing 10,000 steps, it automatically invokes a stored procedure to inject a congratulatory AI message into the user's `chat_history`.
* **`trg_emergency_alert`**: Scans incoming `chat_history`. If the LLM flag `contained_emergency_keywords` is true, an overriding critical alert is generated.

### 4.2 Complex Transactions (PL/SQL Blocks)
* **`sp_process_medical_report`**: A complex PL/SQL block that parses an incoming JSON array of biomarkers, using a cursor to dynamically execute batched `INSERT` statements into multiple health tables, utilizing strict `ROLLBACK` protocols if any single insert fails.
* **`sp_evaluate_step_goal`**: Handles Virtual Nurse daily goal achievement.

### 4.3 Analytics & Optimization (Views & Indexes)
* **Materialized View (`mv_platform_daily_stats`)**: Refreshed concurrently every hour to serve an instant administrative dashboard without hitting the primary transactional tables.
* **B-Tree & GIN Indexing**: Composite indexes on `(user_id, recorded_at)` guarantee O(log N) fetch times for the AI agent context window, while GIN indexes allow full-text search across JSONB biomarker data.

*For the complete SQL code implementations of these features, refer to [DATABASE_ADVANCED_DBMS.md (Sections 5-15)](./DATABASE_ADVANCED_DBMS.md).*
