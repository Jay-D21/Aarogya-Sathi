# Aarogya Sathi — Master Review & Improved Plan

## Deep Audit of All Documentation + Corrected Roadmap

**Reviewer:** Antigravity AI | **Date:** March 31, 2026 | **Scope:** Every document in `docs/`, `devops/`, `research/`, `README.md`, `.gitignore`

> [!IMPORTANT]
> This document does NOT edit the original roadmap or analysis. It is a standalone, comprehensive review that identifies every loophole, contradiction, risk, and gap — then proposes a corrected & improved plan.

---

## Part 1: Loopholes, Contradictions & Things That Will Go Wrong

### 🔴 CRITICAL — These will break the project

#### 1. Table Count Contradiction (13 vs 15 vs 18)
| Document | Claimed Count |
|----------|--------------|
| DATABASE_ADVANCED_DBMS.md (ER section) | 18 tables |
| DATABASE_ADVANCED_DBMS.md (Summary section) | "13 tables + 1 audit table" |
| PROJECT_DESIGN_REPORT.md (Component diagram) | "13 tables" |
| README.md | "15 tables, 40+ indexes" |
| PROJECT_ANALYSIS.md | "18 Tables" |
| PRODUCT_ROADMAP.md | No count specified |

**Problem:** Nobody reading this project will know the actual table count. The DBMS doc header says 18 but its own summary says 13. The README says 15. The PRD references 18.

**Fix:** The actual count in the ER diagram is **18 entities** (USERS through REMINDERS) + **1 audit table** (`health_records_audit`) = **19 tables total**. Update all documents to say **18 core tables + 1 audit table**.

---

#### 2. Missing `backend/` Directory — No Code Exists
The `frontend/` folder is empty. There is no `backend/` folder at all in the project root — only documentation references it. This means:
- `docker-compose.yml` references `./backend` for build → **will fail**
- `Jenkinsfile` references `backend/` → **will fail**
- `README.md` instructions reference `cd backend` → **will fail**
- GitHub Actions reference `backend/` → **will fail**

**Fix:** Create skeleton `backend/` and `frontend/` directories with at minimum a `requirements.txt` / `pubspec.yaml` so nothing crashes on first run.

---

#### 3. `jenkins-installer.msi` (103 MB) Still in Repo
The `.gitignore` has `jenkins-installer.msi` listed, which means it was committed **before** the `.gitignore` was added. Git is still tracking it. The file bloats the repo permanently (even after adding to .gitignore, it's in git history).

**Problem:** Anyone cloning your repo downloads a 103 MB installer they don't need. This can cause GitHub to warn or block pushes.

**Fix:** 
```bash
git rm --cached jenkins-installer.msi
git commit -m "chore: remove jenkins installer binary from tracking"
```
Consider using `git filter-branch` or `BFG Repo-Cleaner` to remove it from history entirely.

---

#### 4. Stored Procedure Uses `COMMIT` Inside → PostgreSQL Will Error
In `sp_log_health_record` (line 618 of DBMS doc):
```sql
COMMIT;  -- ← THIS IS WRONG
```
In PostgreSQL, `COMMIT` inside a stored procedure called from a transaction **will cause an error** unless the procedure was called with `CALL` at the top level. If called from within another transaction or trigger, this will crash.

**Fix:** Remove `COMMIT` from inside the procedure. Let the caller manage transaction boundaries.

---

#### 5. PL/SQL Block Formatting Error — Unclosed Code Fence
In DATABASE_ADVANCED_DBMS.md around line 414-415:
```
414: ```
415: ```
```
Section 2.4 (Reminders specialization) has a **stray closing code fence** immediately followed by section 2.4 again (Aggregation). The markdown is broken — a code block is opened but the content won't render correctly.

**Fix:** Remove the duplicate closing code fence at line 414-415.

---

#### 6. Security Flaw: HS256 JWT with Static Secret
The auth design uses `HS256` (symmetric signing) for JWTs:
```
JWT_SECRET=your-256-bit-secret
JWT_ALGORITHM=HS256
```
**Problem:** HS256 means the same secret is used to both sign and verify tokens. If this secret leaks (via `.env` misconfiguration, logs, error messages), anyone can forge tokens for any user. For a **health data** application, this is a regulatory risk.

**Fix:** Use **RS256** (asymmetric) for production. HS256 is acceptable for development only. The private key signs tokens; the public key verifies them. Even if the public key leaks, tokens can't be forged.

---

#### 7. No Rate Limiting on Registration / Login
The rate limiting design (5 req/min free, unlimited premium) only covers the `/chat/message` endpoint. There's **no mention of rate limiting on auth endpoints**:
- `/register` — attacker can create millions of spam accounts
- `/login` — brute-force attacks possible despite bcrypt

**Fix:** Add explicit rate limits:
- `/register` — 3 requests/minute per IP
- `/login` — 5 attempts/minute per IP, lockout after 10 failed attempts per account

---

#### 8. Subscription Procedure Creates Duplicate Active Subscriptions
`sp_check_subscription_status` (DBMS doc) downgrades expired subscriptions and creates a new `free` subscription. But `sp_create_user` also creates a `free` subscription on registration. If a user upgrades, then expires, they'll have:
1. Original free subscription (from registration)
2. Premium subscription (cancelled)
3. New free subscription (from downgrade)

All three rows exist. The system doesn't deactivate old free subscriptions.

**Fix:** Add `billing_status = 'superseded'` to old subscriptions when creating new ones. Or use a single-row pattern: one subscription per user, updated in place.

---

### 🟡 HIGH — These will cause significant problems

#### 9. WAQI Free Tier Misquoted
| Document | Claimed Free Tier |
|----------|------------------|
| PROJECT_DESIGN_REPORT.md | "10,000 calls/day" |
| TECH_WORKFLOW.md | Not specified |

**Reality:** WAQI's free tier is **1,000 requests/day** with attribution required. 10K/day requires a paid plan. At 10 supported cities polled every 30 minutes, you'd use 480 calls/day — within 1K limit. But if user-initiated calls are counted, it could exceed.

**Fix:** Verify actual quota. Budget for the $50/month WAQI plan as a contingency.

---

#### 10. OpenWeatherMap Free Tier — 1K calls/day Won't Scale
At 10 cities × 48 polls/day (every 30 min) = 480 calls. But each user-initiated `/environment/current` request might also hit the API (if cache misses). With 1,000 users, cache misses alone could exceed 1K/day.

**Fix:** Cache aggressively (already planned). But also budget for the $40/month "Startup" plan as a contingency. Document the exact API budget.

---

#### 11. Google Cloud Vision Free Tier — Only 1,000 req/month
The OCR feature is premium-only, but at ₹99/mo with even 5% conversion on 50K users = 2,500 premium users. If each uploads just 1 report/month, that's 2,500 requests — 2.5× the free tier.

**Fix:** Budget for Cloud Vision costs. At $1.50/1000 requests, this is ~₹300/month initially. Include in cost analysis.

---

#### 12. No Data Backup Strategy Documented
Not a single document mentions:
- Database backup frequency
- Point-in-time recovery (PITR) configuration
- Backup testing/verification
- Disaster recovery plan

For a health data app, losing user health records is catastrophic and possibly illegal under DPDP Act.

**Fix:** Add to DevOps doc:
- Daily automated PostgreSQL backups (pg_dump or WAL archiving)
- 30-day retention
- Weekly backup restoration test
- Multi-region backup storage

---

#### 13. Offline Sync Conflict Resolution — "Server Wins" Is Dangerous
The TECH_WORKFLOW doc states: "Server-wins strategy — local changes are discarded with user notification."

**Problem:** If a user logs BP readings offline for 3 days, then syncs, and the server has no data for those days, "server wins" would mean... the server has nothing, so what happens? The logic is underspecified. Also, silently discarding user health data without clear consent is a DPDP violation.

**Fix:** Use a "last-write-wins with merge" strategy:
- If server has newer data for the same record → server wins
- If only client has data (new records) → client data is accepted
- If both have modified the same record → keep both, mark for user review
- Never silently discard health data

---

#### 14. Missing `height_cm` Column in USERS Table
The roadmap says calories are calculated using the **Mifflin-St Jeor formula**, which requires weight, height, age, gender. The `USERS` table has `date_of_birth` and `gender` but **no `height_cm` column**. The users table in the ER diagram doesn't have it either.

**Fix:** Add `height_cm DECIMAL` to the USERS table schema. Without it, BMI calculation (`fn_calculate_bmi`) and calorie estimation are impossible.

---

#### 15. Missing Fitness Tables in DBMS Doc Summary
The DBMS doc summary says "13 tables," but the ER section defines 18 including `DAILY_STEPS`, `WORKOUTS`, and `REMINDERS`. The actual SQL schema for these 3 fitness tables is **never fully defined** — no CREATE TABLE statements exist in the DBMS doc.

**Fix:** Add complete CREATE TABLE statements for `daily_steps`, `workouts`, and `reminders` in the DBMS doc.

---

#### 16. Roadmap Claims "Custom Reminders" but Schema Only Has 3 Types
The roadmap says:
> Custom Reminders — "Check BP", "Take a walk", anything.

But the `reminder_category` ENUM only has: `'medication', 'water', 'meal', 'custom'`.

The `REMINDERS` table specialization (EER) shows only 3 subtypes: `MED_REM`, `WATER_REM`, `MEAL_REM`. There's no `CUSTOM_REM` subtype despite `'custom'` being in the ENUM.

**Fix:** Add `CUSTOM_REM` subtype with `description TEXT` and `custom_label VARCHAR` attributes.

---

### 🟠 MODERATE — Will cause confusion or waste time

#### 17. Duplicate PRD Files
`AAROGYA_SATHI_PRD_v3_PRIVATE.md` exists in both `docs/` and `research/` (both 32,533 bytes — identical). Editing one won't update the other.

**Fix:** Delete the copy in `research/`. Keep only `docs/` as the source of truth.

---

#### 18. Sprint Timeline is Unrealistic
The DevOps doc plans **6 sprints in 6 weeks** (1 sprint = 1 week). Industry standard sprint length is **2 weeks**. A 1-week sprint gives:
- 5 working days per sprint
- Sprint 1: 22 story points in 5 days = 4.4 SP/day (extremely aggressive)
- Sprint 4 (Voice + OCR): 24 SP in 5 days including Google Cloud integrations

For a small team, this is a recipe for burnout and technical debt.

**Fix:** Recalibrate: 
- Either extend sprints to 2 weeks (12-week project)
- Or reduce scope per sprint (cut P1 items from early sprints)

---

#### 19. `.verdent` Folder — Unexplained
A `.verdent` folder sits in the project root. No document explains what it is. It's not in `.gitignore`.

**Fix:** Investigate. If it's a tool artifact, add to `.gitignore`. If it's needed, document it.

---

#### 20. Cost Analysis Missing Razorpay Fees
The Final Product stage mentions Razorpay for payments (₹99/mo Premium). Razorpay charges **2% + ₹3 per transaction** for UPI/cards.

At ₹99/transaction: fee = ₹2 + ₹3 = ~₹5 per transaction = **5% revenue loss**.

This is not accounted for in the cost analysis.

**Fix:** Add payment gateway fees to the operational costs section.

---

#### 21. No Logging/Monitoring for Free Tier
The DevOps doc mentions structured JSON logging and alerting rules, but doesn't specify **where logs are stored** or **what monitoring tool is used**. "Slack notification" is mentioned for alerts, but no Sentry, Datadog, or CloudWatch setup is documented.

**Fix:** For MVP, use:
- Logging: Structured JSON → file → Loki/ELK (or simple CloudWatch Logs)
- Monitoring: UptimeRobot (free) for health checks
- Error tracking: Sentry (free tier = 5K events/month)

---

#### 22. CORS Configuration — Too Permissive in Dev
The `.env.example` shows:
```
CORS_ORIGINS=http://localhost:3000,https://aarogyasathi.com
```
But the app is Flutter mobile, not a web app. CORS doesn't apply to native mobile HTTP clients. This config suggests a misunderstanding — or there's a planned web dashboard not documented anywhere.

**Fix:** Either:
- Remove CORS config if no web clients are planned
- Or document the web admin dashboard as a planned feature

---

#### 23. `health_emergency` Alert Type Not in ENUM
The emergency trigger (`trg_emergency_alert`) inserts `alert_type = 'health_emergency'`, but the EER diagram shows alert types as: `aqi_spike`, `heatwave`, `cold_wave`, `health_threshold`. 

`health_emergency` is not in the specialization and likely not in the alert_type ENUM (which isn't explicitly defined for alerts — only `alert_severity_level` is defined as an ENUM).

**Fix:** Add `health_emergency` to the alert type ENUM or use the existing `health_threshold` type.

---

---

## Part 2: The Improved Master Plan

### Phase 0: Housekeeping (Day 0 — Before Any Code)

| # | Task | Priority |
|---|------|----------|
| H1 | Remove `jenkins-installer.msi` from git tracking and history | 🔴 Critical |
| H2 | Delete duplicate PRD from `research/` | 🟡 High |
| H3 | Add `.verdent/` to `.gitignore` | 🟠 Medium |
| H4 | Fix all table count references to "18 core + 1 audit" | 🟡 High |
| H5 | Fix the broken code fence in DBMS doc (lines 414-415) | 🟠 Medium |
| H6 | Remove `COMMIT` from `sp_log_health_record` | 🔴 Critical |
| H7 | Add `height_cm` to USERS table schema | 🟡 High |
| H8 | Add CREATE TABLE for `daily_steps`, `workouts`, `reminders` | 🟡 High |
| H9 | Add `CUSTOM_REM` to Reminders specialization | 🟠 Medium |
| H10 | Add `health_emergency` to alert type ENUM | 🟠 Medium |
| H11 | Add `.pptx` files to `.gitignore` (binary bloat) | 🟠 Medium |

---

### Phase 1: Foundation (Weeks 1-2) — 2-Week Sprint

**Sprint Goal:** Backend + DB running, authenticated, basic chat working.

| # | Task | SP | Notes |
|---|------|---|-------|
| 1.1 | Create `backend/` skeleton (FastAPI project structure) | 3 | `app/`, `main.py`, `requirements.txt`, `alembic/` |
| 1.2 | PostgreSQL schema — all 18 tables via Alembic migrations | 5 | Fix all schema inconsistencies first |
| 1.3 | Custom types, domains, ENUMs | 2 | |
| 1.4 | User registration + login (JWT RS256) | 5 | Use RS256 for production security |
| 1.5 | Basic Gemini chat endpoint (no context injection yet) | 5 | System prompt + safety pipeline |
| 1.6 | Health check endpoint (`/health`, `/health/ready`) | 1 | |
| 1.7 | Rate limiting middleware (Redis) | 3 | Include auth endpoints |
| 1.8 | Unit tests for auth + chat | 3 | |
| **Total** | | **27** | ~14 SP/week |

**Key changes from original:**
- RS256 instead of HS256
- Rate limiting on ALL endpoints, not just chat
- Alembic from day one (original didn't even have backend code)
- 2-week sprint instead of 1-week

---

### Phase 2: Health Tracking + Frontend Shell (Weeks 3-4)

**Sprint Goal:** Users can track health, see data, and chat — Flutter connected.

| # | Task | SP | Notes |
|---|------|---|-------|
| 2.1 | Health CRUD endpoints (BP, sugar, symptoms, weight) | 5 | |
| 2.2 | `sp_log_health_record` (fixed — no COMMIT) | 3 | ICMR threshold alerts |
| 2.3 | Health trend endpoints with CTE queries | 3 | |
| 2.4 | Triggers: audit, BP validation, timestamp | 3 | |
| 2.5 | Flutter project creation + auth screens | 5 | |
| 2.6 | Flutter home screen + health tracking screens | 5 | |
| 2.7 | Flutter chat screen (text only) | 5 | |
| 2.8 | SQLite local storage + sync manager skeleton | 3 | |
| **Total** | | **32** | ~16 SP/week |

---

### Phase 3: Fitness + Reminders + Environment (Weeks 5-6)

**Sprint Goal:** Steps tracking, reminders with notifications, AQI display.

| # | Task | SP | Notes |
|---|------|---|-------|
| 3.1 | Fitness CRUD (steps, workouts, sleep, water) | 5 | |
| 3.2 | Pedometer integration (background step counting) | 5 | `pedometer` Flutter package |
| 3.3 | Calorie estimation (Mifflin-St Jeor — needs height!) | 3 | |
| 3.4 | Reminders CRUD + local notifications | 5 | `flutter_local_notifications` |
| 3.5 | Adherence logging (Done/Skipped/Snoozed) | 3 | |
| 3.6 | WAQI + OpenWeatherMap integration + Redis caching | 5 | |
| 3.7 | AQI display card (home screen) | 3 | |
| 3.8 | Context-aware Gemini (inject health + env data) | 5 | |
| **Total** | | **34** | Ambitious but doable |

---

### Phase 4: Voice + Reports + Multilingual (Weeks 7-8)

**Sprint Goal:** Voice I/O, OCR reports, Hindi + Marathi UI.

| # | Task | SP | Notes |
|---|------|---|-------|
| 4.1 | Google Cloud Speech-to-Text integration | 5 | |
| 4.2 | Google Cloud TTS integration | 3 | |
| 4.3 | Medical report upload + Cloud Vision OCR | 8 | Premium feature |
| 4.4 | Biomarker extraction via Gemini | 5 | |
| 4.5 | ICMR comparison + interpretation display | 3 | |
| 4.6 | Flutter `intl` localization (EN, HI, MR) | 5 | |
| 4.7 | Gemini language detection + multilingual response | 3 | |
| **Total** | | **32** | |

---

### Phase 5: Polish + Testing + Security Audit (Weeks 9-10)

**Sprint Goal:** App is stable, secure, and passing all tests.

| # | Task | SP | Notes |
|---|------|---|-------|
| 5.1 | 50+ automated tests (pytest + flutter_test) | 8 | |
| 5.2 | Medical safety test suite (100 cases) | 5 | |
| 5.3 | OWASP security audit | 3 | |
| 5.4 | Performance optimization (<2s p95) | 3 | |
| 5.5 | Offline sync — proper merge strategy (not server-wins) | 5 | |
| 5.6 | Dark mode | 3 | |
| 5.7 | Data export (CSV/PDF) | 3 | |
| 5.8 | Database backup automation + PITR | 3 | |
| 5.9 | Sentry error tracking integration | 2 | |
| **Total** | | **35** | |

---

### Phase 6: Beta Launch + Feedback (Weeks 11-12)

**Sprint Goal:** App on Google Play beta, monitoring live.

| # | Task | SP | Notes |
|---|------|---|-------|
| 6.1 | Docker deployment verified (docker-compose up) | 3 | |
| 6.2 | Google Play beta submission | 5 | |
| 6.3 | 100+ beta testers onboarded | 3 | |
| 6.4 | Feedback submission system | 3 | |
| 6.5 | Analytics dashboard MVP | 5 | |
| 6.6 | Monitoring setup (UptimeRobot + Sentry) | 3 | |
| 6.7 | Documentation final review + update | 2 | |
| **Total** | | **24** | |

---

## Part 3: Corrected Technical Decisions

### Auth: RS256 Instead of HS256
```
JWT_ALGORITHM=RS256
JWT_PRIVATE_KEY_PATH=./keys/jwt-private.pem
JWT_PUBLIC_KEY_PATH=./keys/jwt-public.pem
```

### Offline Sync: Merge Strategy Instead of Server-Wins
```
IF record exists on server AND client:
    IF server.updated_at > client.updated_at:
        → Keep server version
    ELSE:
        → Keep client version
        
IF record exists ONLY on client:
    → Upload to server (ALWAYS accept new client data)
    
IF record exists ONLY on server:
    → Download to client

NEVER silently discard health data.
```

### Subscription: Single Row Per User
```sql
-- Instead of multiple subscription rows, use one row updated in place:
-- Add UNIQUE constraint: (user_id) — only one active subscription per user
ALTER TABLE subscriptions ADD CONSTRAINT uq_user_subscription UNIQUE (user_id);
```

### API Cost Budget (Corrected)

| Service | Free Tier | Expected Monthly Usage | Est. Monthly Cost |
|---------|-----------|----------------------|-------------------|
| Gemini 2.0 Flash | 1.5M tokens/day | ~2M tokens/day (at 1K users) | ₹2,000-5,000 |
| WAQI | 1,000 calls/day | ~500 calls/day | Free (within limit) |
| OpenWeatherMap | 1,000 calls/day | ~500 calls/day | Free (within limit) |
| Cloud Vision | 1,000/month | ~2,500/month (premium users) | ₹250/month |
| Cloud Speech | 60 min/month | ~500 min/month | ₹5,000/month |
| Cloud TTS | 4M chars/month | ~2M chars/month | Free (within limit) |
| Razorpay | N/A | ~2,500 transactions | ~₹12,500 (5% of ₹2.5L) |
| **Total** | | | **₹20,000-25,000/month** |

---

## Part 4: Risk Register (Updated)

| # | Risk | Likelihood | Impact | Mitigation | Owner |
|---|------|-----------|--------|------------|-------|
| R1 | Medical liability lawsuit | Medium | Critical | Medical advisory board, disclaimers in every response, clear ToS, liability insurance ₹5L/yr | Legal |
| R2 | Gemini hallucinates medical advice | High | Critical | Backend safety filter (regex + NLP), fallback responses, never trust Gemini alone | Backend |
| R3 | API costs exceed budget | Medium | High | Redis caching, rate limiting, Flash Lite fallback, daily cost monitoring alerts | DevOps |
| R4 | JWT secret leaked | Low | Critical | Use RS256 (asymmetric), rotate keys quarterly, never log tokens | Security |
| R5 | Data breach → DPDP violation | Low | Critical | AES-256, RLS, no PII to Gemini, SOC 2 audit | Security |
| R6 | Offline data loss | Medium | High | Proper merge sync (not server-wins), SQLite WAL mode, backup before sync | Mobile |
| R7 | GitHub repo bloat (binary files) | Already happening | Medium | Remove `.msi` from history, add `.pptx` to gitignore, use Git LFS for binaries | DevOps |
| R8 | Sprint burnout (1-week sprints) | High | High | Switch to 2-week sprints as proposed in this plan | PM |
| R9 | Free tier API limits exceeded | Medium | Medium | Monitor usage, budget for paid tiers, progressive feature rollout | DevOps |
| R10 | App store rejection for health claims | Low | High | Clear "not a medical device" disclaimer, no diagnostic claims in store listing | PM |

---

## Part 5: Immediate Action Items (Do Today)

1. ✅ `git rm --cached jenkins-installer.msi` — stop tracking the 103MB installer
2. ✅ Fix `.gitignore` — add `*.pptx`, `.verdent/`
3. ✅ Delete duplicate PRD from `research/`
4. ✅ Fix DBMS doc: remove `COMMIT` from SP, fix code fence, fix table count
5. ✅ Add `height_cm` to USERS table schema in DBMS doc
6. ✅ Create empty `backend/` with `requirements.txt` placeholder
7. ✅ Create `docs/BACKUP_AND_DR_PLAN.md` — document backup strategy

---

## Summary

| Category | Issues Found |
|----------|-------------|
| 🔴 Critical (will break things) | 8 |
| 🟡 High (significant problems) | 8 |
| 🟠 Moderate (confusion/waste) | 7 |
| **Total Issues** | **23** |

The original roadmap is **well-intentioned but unrealistic in timeline** (6 weeks with 1-week sprints) and contains **contradictions across documents** that will confuse any developer joining the project. The database schema has **real bugs** (COMMIT in procedure, missing columns, unclosed code fences) that would cause runtime errors.

The improved plan extends the timeline to **12 weeks with 2-week sprints**, fixes all identified bugs, adds missing infrastructure (backups, monitoring, proper sync), and corrects security decisions (RS256 over HS256).

**The project's documentation quality is genuinely impressive — but documentation without code is vapor. The #1 priority is to start writing actual application code.**

---

**Document Status:** ✅ Complete
**Version:** 1.0 | **Created:** March 31, 2026
