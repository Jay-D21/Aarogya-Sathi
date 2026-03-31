# Aarogya Sathi — Complete Project Analysis

## 📌 What is This Project?

**Aarogya Sathi (आरोग्य साथी — "Health Companion")** is a **mobile-first AI-powered health assistant** designed for **urban India**. It combines AI chat (Google Gemini), real-time environmental data (AQI + weather), multilingual voice support (Hindi, Marathi, English), and ICMR-compliant health awareness — all in one app. It is NOT a diagnostic tool — it's a health awareness companion with strict safety boundaries.

---

## 🎯 Objectives

- Provide **environment-aware health guidance** (correlating AQI/weather with personalized advice)
- Operate in **3 Indian languages** (Hindi, Marathi, English) with voice I/O
- **Track health metrics** (BP, blood sugar, symptoms) with trend visualization
- **Process medical reports** via OCR with ICMR-guided interpretation
- Maintain **strict medical safety** — zero diagnosis, zero prescriptions, mandatory disclaimers
- Support a **freemium B2C model** (Free + ₹99/mo Premium) and **B2B corporate wellness**

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) — cross-platform mobile |
| Backend | Python FastAPI — async REST API |
| AI Engine | Google Gemini 2.0 Flash — 700+ line system prompt |
| Primary DB | PostgreSQL 15+ — 18 tables, BCNF, RLS |
| Local DB | SQLite — offline-first on device |
| Cache | Redis 7 — sessions, rate limiting, API caching |
| OCR | Google Cloud Vision |
| Voice | Google Cloud Speech/TTS |
| AQI | WAQI API |
| Weather | OpenWeatherMap |
| CI/CD | Jenkins + GitHub Actions |
| Containers | Docker + docker-compose (backend, PostgreSQL, Redis, Nginx) |

---

## 📊 Database Entities (18 Tables)

| # | Entity | Purpose |
|---|--------|---------|
| 1 | **USERS** | Core profile, auth, preferences |
| 2 | **HEALTH_RECORDS** | BP, sugar, symptoms, lifestyle, medication (single-table inheritance via `record_type`) |
| 3 | **CHAT_HISTORY** | AI chat messages + responses + token usage |
| 4 | **MEDICAL_REPORTS** | Uploaded reports with OCR biomarkers (JSONB) |
| 5 | **ENVIRONMENTAL_ALERTS** | AQI, heatwave, cold wave alerts |
| 6 | **HEALTH_CONDITIONS** | Chronic conditions (diabetes, hypertension) |
| 7 | **USER_PREFERENCES** | Notifications, voice, dark mode settings |
| 8 | **AUTH_SESSIONS** | JWT sessions, device tracking |
| 9 | **ABDM_INTEGRATIONS** | ABHA health ID linkage (future) |
| 10 | **SUBSCRIPTIONS** | Free/Premium plan management |
| 11 | **USER_ANALYTICS** | Daily usage metrics |
| 12 | **API_USAGE** | Per-request token/cost tracking |
| 13 | **USER_FEEDBACK** | App ratings and feedback |
| 14 | **CORPORATE_ACCOUNTS** | Employer wellness programs |
| 15 | **CORPORATE_EMP_MAP** | Maps users to corporate accounts |
| 16 | **DAILY_STEPS** | Virtual Nurse: daily step logs |
| 17 | **WORKOUTS** | Virtual Nurse: exercise tracking |
| 18 | **REMINDERS** | Virtual Nurse: meds, water, meals |

### EER Specializations (IS-A Hierarchies)
- **HEALTH_RECORDS** → Vitals, Symptoms, Lifestyle, Medication (Disjoint, Total)
- **SUBSCRIPTIONS** → Free, Premium (Disjoint, Total)
- **ENVIRONMENTAL_ALERTS** → AQI_Spike, Heatwave, Cold_Wave, Health_Threshold (Disjoint, Partial)
- **REMINDERS** → Medication, Water, Meal (Disjoint, Total)

---

## ⚙️ All Functionalities

### Core Features (P0 — Critical)
- **Multilingual Health Chat** — text + voice AI chat in Hindi, Marathi, English via Gemini 2.0 Flash with 700+ line system prompt
- **Real-Time Environmental Awareness** — AQI + weather data woven into every health response
- **Health Tracking & History** — BP, blood sugar, symptoms, weight, sleep, exercise, water, stress, diet, medication logging with offline-first SQLite sync

### High Priority Features (P1)
- **Medical Report OCR** — photograph blood tests → Cloud Vision OCR → Gemini biomarker extraction → ICMR comparison
- **Voice Input/Output** — Google Cloud Speech (STT) + TTS in 3 languages
- **Proactive Health Recommendations** — daily personalized tips based on health history + environment + ICMR

### Safety & Compliance
- **Zero Diagnosis / Zero Prescription** — enforced at system-prompt level AND backend safety pipeline
- **Emergency Detection** — detects chest pain, stroke symptoms → "Call 108 NOW"
- **Mandatory Disclaimers** — every AI response must include a medical disclaimer
- **DPDP Act (India) Compliance** — user data deletion within 30 days, no PII sent to Gemini

### Backend Features
- **JWT Authentication** — register, login, refresh-token, logout, verify
- **Rate Limiting** — Redis-backed (5 req/min free, unlimited premium)
- **Subscription Management** — Free vs Premium, auto-expiry/downgrade
- **Corporate B2B** — employer wellness accounts, employee mapping
- **Analytics** — user engagement, API cost tracking, materialized views
- **Feedback System** — user ratings and bug reports

### Database Advanced Features (PL/SQL)
- **6 Stored Procedures** — `sp_create_user`, `sp_log_health_record`, `sp_generate_analytics_report`, `sp_process_environmental_alerts`, `sp_check_subscription_status`, `sp_evaluate_step_goal`
- **13 Active Triggers** — auto-compute age, step goal achievement, emergency alert, API usage logging, etc.
- **Functions** — BMI calculator, AQI level decoder, ICMR range checker, health risk scorer
- **Views & Materialized Views** — `mv_platform_daily_stats` for admin dashboard
- **CTEs & Window Functions** — health trends, 7-day moving averages
- **Row-Level Security (RLS)** — users can only access their own data
- **B-Tree + GIN Indexing** — O(log N) fetch, full-text search on JSONB biomarkers
- **Partitioning** — range partitioning on `chat_history` by month

### DevOps & CI/CD
- **Jenkins Pipeline** — code → lint → test → build → deploy
- **GitHub Actions** — supplementary CI for backend and frontend
- **Docker Compose** — backend + PostgreSQL + Redis + Nginx
- **GitFlow** — main, develop, feature/*, bugfix/*, release/*, hotfix/*
- **SemVer** — semantic versioning for releases

---

## ✅ What IS in This Project (What Exists)

| Item | Status |
|------|--------|
| Comprehensive PRD (Product Requirements Document) | ✅ Complete |
| Project Design Report (architecture, DFDs, UML, sequence diagrams) | ✅ Complete |
| Advanced DBMS Document (ER/EER, SQL schema, PL/SQL, triggers, cursors, views, indexes, partitioning, RLS) | ✅ Complete |
| Interactive ER Diagram (HTML) | ✅ Complete |
| Interactive EER Diagram (HTML) | ✅ Complete |
| DBMS Project Report (summary) | ✅ Complete |
| Tech Workflow Document (end-to-end data flows, caching, offline sync, error handling) | ✅ Complete |
| DevOps/SDLC/Agile Document (6 sprints, CI/CD, Git workflow, release management) | ✅ Complete |
| Jenkinsfile | ✅ Complete |
| Dockerfiles (backend + frontend) | ✅ Complete |
| docker-compose.yml | ✅ Complete |
| GitHub Actions CI (backend + frontend) | ✅ Complete |
| .env.example | ✅ Complete |
| Gemini System Prompt (700+ lines) | ✅ In research |
| API Specification | ✅ In research |
| Implementation Guide | ✅ In research |
| MVP Summary + Checklists | ✅ In research |
| PowerPoint Presentations (3 versions) | ✅ Complete |
| README with project overview | ✅ Complete |
| Research PDF (Aavishkar 2025 report) | ✅ Complete |

---

## ❌ What is MISSING (Not Yet Built)

> [!CAUTION]
> The actual application code has NOT been written yet. Both `backend/` and `frontend/` folders are empty.

| Missing Item | Impact |
|-------------|--------|
| **Backend (FastAPI)** — all Python code: routes, services, models, schemas, DB migrations, tests | 🔴 Critical |
| **Frontend (Flutter)** — all Dart code: screens, widgets, providers, services, models | 🔴 Critical |
| **Database** — actual PostgreSQL/Supabase database not provisioned | 🔴 Critical |
| **API Keys** — no actual Google Cloud, WAQI, OpenWeatherMap keys configured | 🟡 Medium |
| **Tests** — no pytest or flutter_test suites exist | 🟡 Medium |
| **Alembic Migrations** — no migration files | 🟡 Medium |

---

## 🤔 What Should & Shouldn't Be There

### ✅ Things That SHOULD Be There (and are — good)
- Detailed PRD before code → excellent planning
- ER/EER diagrams with all 18 entities → strong database design
- PL/SQL procedures, triggers, cursors → demonstrates advanced DBMS knowledge
- Normalization proof (1NF → BCNF) → academic rigor
- Safety pipeline design → responsible AI
- DevOps pipeline before code → professional approach
- Offline-first architecture with SQLite sync → practical for India
- Cost analysis → realistic business thinking

### ⚠️ Things That SHOULD Be There (but are NOT)
- **Actual working code** (backend + frontend) — the project is 100% documentation
- **A running prototype** — at least a basic chat screen + API endpoint
- **Database setup script** — the `create_db.py` in research is only 860 bytes
- **Unit tests / integration tests** — no test code exists
- **API key management** — `.env.example` exists but no secrets management solution
- **Error tracking service** — no Sentry/Crashlytics integration (was researched per conversation history)

### ❌ Things That SHOULD NOT Be There
- **`jenkins-installer.msi` (103 MB)** in root — installer binaries should not be in a Git repo; add to `.gitignore`
- **Duplicate PRD** — `AAROGYA_SATHI_PRD_v3_PRIVATE.md` exists in both `docs/` and `research/` (identical 32,533 bytes)
- **`.verdent` folder** — unclear purpose, likely a leftover or tool artifact
- **Presentation files** (`.pptx`) — 3 versions totaling ~7.7 MB; should not be tracked in Git (binary files bloat the repo)

---

## 📝 Summary

**Aarogya Sathi is a very well-documented and well-planned project, but it is entirely in the design/planning phase.** The documentation quality is excellent — PRD, database design, DevOps pipelines, tech workflows, and ER diagrams are all comprehensive and professional-grade. However, **zero lines of actual application code** have been written. The `frontend/` and `backend/` folders are empty.

The project needs to transition from documentation to implementation, starting with Sprint 1 (Backend Foundation) as outlined in the DevOps document.
