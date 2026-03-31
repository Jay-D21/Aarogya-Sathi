---
marp: true
theme: default
size: 16:9
paginate: true
header: "**Aarogya Sathi** — Advanced DBMS"
footer: "DBMS Architecture Presentation | 2026"
style: |
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Montserrat:wght@600;800&display=swap');
  
  section {
    font-family: 'Inter', sans-serif;
    font-size: 26px; /* Base font size */
    padding: 60px 80px; 
    background-color: #f8fafc;
    color: #334155;
  }
  
  h1, h2, h3 {
    font-family: 'Montserrat', sans-serif;
    margin-top: 0;
  }

  h1 {
    font-size: 2.2em;
    color: #0f172a;
    border-bottom: 4px solid #3b82f6;
    padding-bottom: 10px;
    margin-bottom: 30px;
  }

  h2 {
    font-size: 1.6em;
    color: #1e3a8a;
    margin-bottom: 25px;
  }

  h3 {
    font-size: 1.2em;
    color: #0d9488;
  }

  p, li {
    line-height: 1.5;
  }

  /* Specific Layouts */
  .title-slide {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
  }

  .title-slide h1 {
    font-size: 3.5em;
    border: none;
    margin-bottom: 10px;
    background: -webkit-linear-gradient(45deg, #1e40af, #0d9488);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .title-slide h2 {
    font-size: 1.5em;
    color: #64748b;
    font-weight: 400;
  }

  .grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 40px;
  }

  .grid-3 {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 30px;
  }

  .card {
    background: white;
    padding: 25px;
    border-radius: 12px;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    border-top: 5px solid #3b82f6;
  }

  .card.green { border-color: #10b981; }
  .card.red { border-color: #ef4444; }

  table {
    width: 100%;
    margin-top: 20px;
    font-size: 0.9em;
    border-collapse: collapse;
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  }

  th {
    background-color: #f1f5f9;
    color: #1e293b;
    padding: 12px;
    text-align: left;
  }

  td {
    padding: 12px;
    border-top: 1px solid #e2e8f0;
  }

  code {
    background-color: #e2e8f0;
    color: #b91c1c;
    padding: 2px 6px;
    border-radius: 4px;
    font-size: 0.85em;
  }
  
  .badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 20px;
    color: white;
    background: #2563eb;
    font-size: 0.75em;
    font-weight: 600;
  }
---

<!-- _class: title-slide -->

# Aarogya Sathi (आरोग्य साथी)
## Advanced DBMS Architecture

**Project Presentation** | **March 2026**

---

# 1. Project Overview & Tech Stack

Aarogya Sathi is an AI Health Companion built to process real-time vitals, environmental data, and medical OCR intelligently.

<div class="grid-3">
  <div class="card">
    <h3>📱 Front-End</h3>
    <ul>
      <li>Flutter (Cross-platform)</li>
      <li>SQLite (Offline data)</li>
    </ul>
  </div>
  <div class="card">
    <h3>⚙️ Back-End</h3>
    <ul>
      <li>Python FastAPI</li>
      <li>Redis 7 (Caching)</li>
    </ul>
  </div>
  <div class="card">
    <h3>🧠 Data & AI</h3>
    <ul>
      <li><b>PostgreSQL 15</b> (Core)</li>
      <li>Gemini 2.0 Flash (AI)</li>
    </ul>
  </div>
</div>

---

# 2. Database Design Philosophy

Built for **High Transaction Volume** & **Data Integrity** in medical telemetry.

<div class="grid-2">
  <div>
    <h3>Why PostgreSQL?</h3>
    <ul>
      <li><span class="badge">JSONB</span> for unstructured OCR biomarkers.</li>
      <li><span class="badge">ACID</span> Strict compliance for clinical data.</li>
      <li><span class="badge">PL/pgSQL</span> for advanced automated logic.</li>
    </ul>
  </div>
  <div>
    <h3>Normalization</h3>
    <ul>
      <li>18 distinct tables.</li>
      <li>Strictly <b>Boyce-Codd Normal Form (BCNF)</b>.</li>
      <li>Complete elimination of partial dependencies.</li>
    </ul>
  </div>
</div>

---

# 3. Conceptual Design: ER Overview

The schema is divided into distinct logical domains centered around the User.

<div class="grid-3">
  <div class="card">
    <h3>👤 Central Hub</h3>
    <p><code>USERS</code> entity interacts via 1:N relations to all telemetry.</p>
  </div>
  <div class="card">
    <h3>🏥 Telemetry</h3>
    <p><code>HEALTH_RECORDS</code><br><code>MEDICAL_REPORTS</code><br><code>HEALTH_CONDITIONS</code></p>
  </div>
  <div class="card">
    <h3>🏃‍♂️ Virtual Nurse</h3>
    <p><code>DAILY_STEPS</code><br><code>WORKOUTS</code><br><code>REMINDERS</code></p>
  </div>
</div>

---

# 4. Enhanced ER (EER) Constraints

Object-Oriented Subtyping minimizes `NULL` values and tightens constraints.

| Superclass | Subclasses (Total & Disjoint) |
|---|---|
| **HEALTH_RECORDS** | Vitals, Symptoms, Lifestyle, Medication |
| **SUBSCRIPTIONS** | Free (₹0), Premium (₹99) |
| **REMINDERS** | Medication, Water, Meal |
| **ENV_ALERTS** | AQI Spike, Heatwave, Cold Wave, Threshold |

*(Implemented via Single-Table Inheritance and Custom `ENUM` domains)*

---

# 5. Advanced DBMS Automation

Pushing business logic down to the database minimizes application overhead.

<div class="grid-3">
  <div class="card">
    <h3>Procedures</h3>
    <p>Multi-table transactions to atomicize user workflows.</p>
  </div>
  <div class="card red">
    <h3>Active Triggers</h3>
    <p>Immediate, event-driven safety interventions.</p>
  </div>
  <div class="card green">
    <h3>Functions</h3>
    <p>Reusable mathematical & categorical computations.</p>
  </div>
</div>

---

# 6. Critical Stored Procedures

### ⚡ `sp_log_health_record()`
- **Triggered When:** User logs a new vital sign.
- **Action:** Inserts the reading. If **BP > 180** or **Sugar > 200**, the procedure immediately spawns a `CRITICAL` alert in `ENV_ALERTS` without backend intervention.

### 👤 `sp_create_user()`
- **Action:** Atomically creates the `USER`, provisions default `USER_PREFERENCES`, assigns a 'Free' `SUBSCRIPTION`, and initializes Daily `ANALYTICS`.

---

# 7. Automated Workflows (Triggers)

**1. `trg_emergency_alert`**
Scans `CHAT_HISTORY` inserts. If the LLM flag `contained_emergency_keywords` is active, it dispatches an immediate safety notification override.

**2. `trg_daily_summary_check`**
Monitors `DAILY_STEPS`. Upon crossing 10,000 steps, it dynamically inserts a congratulatory AI message directly into the chat stream.

**3. `trg_calculate_derived_age`**
Automatically updates current age dynamically when the `DOB` is inserted.

---

# 8. Indexing & Optimization

Ensuring sub-second fetches for AI prompt injection.

<div class="grid-2">
  <div class="card">
    <h3>Composite B-Tree Indexes</h3>
    <p>Targeting <code>(user_id, recorded_at)</code> on telemetry tables guarantees <b>O(log N)</b> fetching for historical chat context.</p>
  </div>
  <div class="card">
    <h3>GIN (Inverted Indexes)</h3>
    <p>Applied to <code>biomarkers JSONB</code> column in reports. Enables extremely fast full-text searching across deeply nested extraction payloads.</p>
  </div>
</div>

---

<!-- _class: title-slide -->

# Thank You!
**Aarogya Sathi DBMS Architecture**

<br>
<p style="font-size: 0.6em; color: #64748b; font-weight: 600;">
Questions on BCNF, EER, or PL/SQL Implementations?
</p>
