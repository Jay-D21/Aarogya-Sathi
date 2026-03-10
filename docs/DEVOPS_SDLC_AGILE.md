# AAROGYA SATHI — DevOps, SDLC & Agile Methodology
## Sprints, CI/CD Pipeline, Git Workflow & Release Management

**Version:** 3.0 | **Date:** March 10, 2026

---

## Table of Contents

1. [SDLC Model Selection](#1-sdlc-model-selection)
2. [Agile Scrum Framework](#2-agile-scrum-framework)
3. [Sprint Planning (6 Sprints)](#3-sprint-planning)
4. [Git Workflow (GitFlow)](#4-git-workflow)
5. [CI/CD Pipeline](#5-cicd-pipeline)
6. [Docker Deployment](#6-docker-deployment)
7. [Environment Management](#7-environment-management)
8. [Monitoring & Observability](#8-monitoring--observability)
9. [Release Management](#9-release-management)
10. [Quality Gates](#10-quality-gates)

---

## 1. SDLC Model Selection

### Model: Agile (Scrum Framework)

**Why Agile for Aarogya Sathi:**

| Factor | Agile Advantage |
|--------|----------------|
| Requirement Evolution | Health AI features evolve with user feedback |
| Fast Time-to-Market | 6-week MVP sprint cycle |
| Risk Mitigation | Early detection of medical safety issues |
| Stakeholder Feedback | Iterative demos with medical advisory board |
| Team Size | Small team → low ceremony Scrum |

### SDLC Phases Mapping

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│ Planning │──>│  Design  │──>│  Develop │──>│   Test   │──>│  Deploy  │
│ (Sprint  │   │ (Sprint  │   │ (Sprint  │   │ (Sprint  │   │ (Sprint  │
│ Planning)│   │ Backlog) │   │ Execution│   │ Review)  │   │ Release) │
└──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
      ↑                                                            │
      └────────────── Sprint Retrospective ◄───────────────────────┘
```

---

## 2. Agile Scrum Framework

### 2.1 Scrum Roles

| Role | Person/Team | Responsibilities |
|------|------------|-----------------|
| **Product Owner** | Project Lead | Prioritize backlog, define acceptance criteria, stakeholder communication |
| **Scrum Master** | Tech Lead | Remove blockers, facilitate ceremonies, ensure process adherence |
| **Dev Team** | Full-stack developers | Design, develop, test, deploy |

### 2.2 Scrum Ceremonies

| Ceremony | Frequency | Duration | Purpose |
|----------|-----------|----------|---------|
| Sprint Planning | Start of each sprint | 2 hours | Select user stories, estimate story points |
| Daily Standup | Daily | 15 minutes | What I did, what I'll do, any blockers |
| Sprint Review | End of each sprint | 1 hour | Demo completed features, stakeholder feedback |
| Sprint Retrospective | End of each sprint | 30 minutes | What went well, what to improve, action items |
| Backlog Grooming | Mid-sprint | 1 hour | Refine upcoming stories, re-estimate |

### 2.3 Story Point Scale

| Points | Effort | Example |
|--------|--------|---------|
| 1 | Trivial | Fix a typo, update config |
| 2 | Small | Add a new API endpoint (CRUD) |
| 3 | Medium | Integrate a new external API |
| 5 | Large | Build health tracking module |
| 8 | XL | Implement Gemini chat with safety pipeline |
| 13 | Epic-sized | Full OCR + report analysis pipeline |

### 2.4 Definition of Done (DoD)

- [ ] Code written and passes linting (flake8/dart analyze)
- [ ] Unit tests written and passing (>80% coverage)
- [ ] Integration test passing for API endpoints
- [ ] Code reviewed by at least 1 team member
- [ ] Documentation updated (API docs, README)
- [ ] No critical security vulnerabilities
- [ ] Medical safety tests passing (if applicable)
- [ ] Feature demo'd in Sprint Review

---

## 3. Sprint Planning

### Sprint 1: Backend Foundation (Week 1)

**Sprint Goal:** API backend ready to receive authenticated requests and return Gemini responses.

| # | User Story | Story Points | Priority | Acceptance Criteria |
|---|-----------|-------------|----------|-------------------|
| US-1 | As a user, I want to register with email/phone | 3 | P0 | POST /register returns 201, user in DB |
| US-2 | As a user, I want to login and get JWT | 3 | P0 | POST /login returns access + refresh tokens |
| US-3 | As a user, I want to chat with AI about health | 8 | P0 | POST /chat/message returns Gemini response with disclaimer |
| US-4 | As a system, I need DB schema with migrations | 5 | P0 | All 15 tables created via Alembic |
| US-5 | As a developer, I need project structure setup | 2 | P0 | FastAPI project runs on localhost:8000 |
| US-6 | As a system, I need health check endpoint | 1 | P0 | GET /health returns 200 |

**Total:** 22 story points | **Velocity Target:** 20-25 SP

---

### Sprint 2: Health Tracking + Frontend Shell (Week 2)

**Sprint Goal:** Users can track BP/sugar and see a working Flutter app.

| # | User Story | SP | Priority | Acceptance Criteria |
|---|-----------|---|----------|-------------------|
| US-7 | As a user, I want to log my blood pressure | 3 | P0 | POST /health/bp-reading stores record, returns ICMR comparison |
| US-8 | As a user, I want to log my blood sugar | 3 | P0 | POST /health/sugar-reading stores record |
| US-9 | As a user, I want to log symptoms | 3 | P0 | POST /health/symptom-log stores with AQI correlation |
| US-10 | As a user, I want to see health history | 3 | P0 | GET /health/records returns paginated data |
| US-11 | As a mobile user, I want login/register screens | 5 | P0 | Flutter auth screens connect to API |
| US-12 | As a mobile user, I want a home screen | 3 | P0 | Dashboard with health summary |
| US-13 | As a mobile user, I want a chat screen | 5 | P0 | Text input → API → display response |

**Total:** 25 SP

---

### Sprint 3: Environmental Integration (Week 3)

**Sprint Goal:** AQI and weather data integrated into chat and alerts.

| # | User Story | SP | Priority | Acceptance Criteria |
|---|-----------|---|----------|-------------------|
| US-14 | As a system, I need WAQI API integration | 3 | P0 | AQI data fetched and cached in Redis |
| US-15 | As a system, I need OpenWeather integration | 3 | P0 | Weather data fetched and cached |
| US-16 | As a user, I want AQI alerts | 5 | P0 | GET /environment/alerts returns alerts when AQI>300 |
| US-17 | As a user, I want environment-aware chat | 5 | P0 | Chat responses include AQI context |
| US-18 | As a mobile user, I want AQI display screen | 3 | P1 | AQI dashboard with color-coded indicator |
| US-19 | As a system, I need Redis caching layer | 3 | P0 | ENV data cached 1hr, health context 24hr |

**Total:** 22 SP

---

### Sprint 4: Voice + Medical Reports (Week 4)

**Sprint Goal:** Voice I/O and medical report OCR working.

| # | User Story | SP | Priority | Acceptance Criteria |
|---|-----------|---|----------|-------------------|
| US-20 | As a user, I want to speak my health query | 5 | P1 | Voice → Cloud Speech → text → Gemini → response |
| US-21 | As a user, I want AI to read responses aloud | 3 | P1 | TTS plays response in selected language |
| US-22 | As a user, I want to upload medical reports | 8 | P1 | Image → Cloud Vision OCR → biomarker extraction |
| US-23 | As a user, I want to see report analysis | 5 | P1 | Biomarkers vs ICMR ranges displayed |
| US-24 | As a mobile user, I want voice input widget | 3 | P1 | Tap mic → record → transcribe |

**Total:** 24 SP

---

### Sprint 5: Polish + Testing (Week 5)

**Sprint Goal:** App stable, secure, and passing all tests.

| # | User Story | SP | Priority | Acceptance Criteria |
|---|-----------|---|----------|-------------------|
| US-25 | As a dev, I need 50+ automated tests | 8 | P0 | pytest + flutter_test passing |
| US-26 | As a dev, I need medical safety test suite | 5 | P0 | 0 diagnosis/Rx claims in 100 test cases |
| US-27 | As a dev, I need security audit | 3 | P0 | No OWASP Top 10 vulnerabilities |
| US-28 | As a user, I want smooth UI animations | 3 | P1 | 60fps Flutter animations |
| US-29 | As a dev, I need performance optimization | 3 | P1 | <2s API p95 response time |
| US-30 | As a dev, I need Docker deployment config | 3 | P1 | docker-compose up works end-to-end |

**Total:** 25 SP

---

### Sprint 6: Beta Launch (Week 6)

**Sprint Goal:** App on Google Play beta with 100+ testers.

| # | User Story | SP | Priority | Acceptance Criteria |
|---|-----------|---|----------|-------------------|
| US-31 | As a PM, I need Play Store beta submission | 5 | P0 | APK uploaded, beta track active |
| US-32 | As a PM, I need 100+ beta testers | 3 | P0 | Testers invited and onboarded |
| US-33 | As a user, I want feedback submission | 3 | P0 | POST /feedback/submit works |
| US-34 | As a PM, I need analytics dashboard | 5 | P1 | Usage metrics visible |
| US-35 | As a dev, I need monitoring setup | 3 | P1 | Health endpoints, logging, error tracking |

**Total:** 19 SP

---

### Sprint Velocity Summary

| Sprint | Planned SP | Target Velocity | Theme |
|--------|-----------|----------------|-------|
| Sprint 1 | 22 | 20-25 | Backend Foundation |
| Sprint 2 | 25 | 20-25 | Health + Frontend |
| Sprint 3 | 22 | 20-25 | Environment |
| Sprint 4 | 24 | 20-25 | Voice + Reports |
| Sprint 5 | 25 | 20-25 | Testing + Polish |
| Sprint 6 | 19 | 15-20 | Beta Launch |
| **Total** | **137** | — | **6-week MVP** |

---

## 4. Git Workflow

### 4.1 GitFlow Model

```
main ─────────────────────────────────────────────────────► stable releases
  │                                                    ▲
  │                                                    │
  ├── develop ────────────────────────────────────────►│ merge
  │     │                              ▲               │
  │     ├── feature/auth ──────────────┤               │
  │     ├── feature/chat ──────────────┤               │
  │     ├── feature/health ────────────┤               │
  │     ├── feature/environment ───────┤               │
  │     ├── feature/voice-reports ─────┤               │
  │     ├── feature/documentation ─────┤               │
  │     └── feature/devops-setup ──────┘               │
  │                                                    │
  ├── release/v1.0.0 ─────────────────────────────────►│
  │                                                    │
  ├── hotfix/critical-safety-fix ──────────────────────┘
  │
  └── bugfix/fix-login-error ──► develop
```

### 4.2 Branch Naming Convention

| Branch Type | Pattern | Example |
|-------------|---------|---------|
| Main | `main` | `main` |
| Development | `develop` | `develop` |
| Feature | `feature/{sprint}-{short-desc}` | `feature/s1-auth-jwt` |
| Bugfix | `bugfix/{issue-id}-{short-desc}` | `bugfix/42-login-crash` |
| Release | `release/v{major}.{minor}.{patch}` | `release/v1.0.0` |
| Hotfix | `hotfix/{short-desc}` | `hotfix/safety-filter-bypass` |

### 4.3 Commit Message Convention

```
<type>(<scope>): <short description>

Types: feat, fix, docs, style, refactor, test, chore, ci
Scope: auth, chat, health, reports, env, frontend, db, devops

Examples:
  feat(chat): add Gemini API integration with safety filter
  fix(auth): resolve JWT refresh token expiry issue
  docs(db): add ER diagram and trigger documentation
  test(health): add BP validation edge case tests
  ci(jenkins): add Flutter analyze stage to pipeline
```

### 4.4 Pull Request Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Feature
- [ ] Bug fix
- [ ] Documentation
- [ ] Refactor

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests passing
- [ ] Medical safety tests passing (if applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No hardcoded secrets
```

---

## 5. CI/CD Pipeline

### 5.1 Pipeline Architecture

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│   CODE   │───>│   LINT   │───>│   TEST   │───>│  BUILD   │───>│  DEPLOY  │
│  (Push)  │    │          │    │          │    │          │    │          │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
                     │               │               │               │
                 ┌───┴───┐      ┌───┴───┐      ┌───┴───┐      ┌───┴───┐
                 │flake8 │      │pytest │      │Docker │      │Deploy │
                 │dart   │      │flutter│      │APK    │      │to env │
                 │analyze│      │test   │      │build  │      │       │
                 └───────┘      └───────┘      └───────┘      └───────┘
```

### 5.2 Jenkins Pipeline (Existing Jenkinsfile — Enhanced)

```groovy
pipeline {
    agent any

    environment {
        FLUTTER_HOME = tool(name: 'Flutter SDK', type: 'com.example.FlutterInstallation') ?: ''
        PYTHON_HOME  = tool(name: 'Python', type: 'jenkins.plugins.shiningpanda.tools.PythonInstallation') ?: ''
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Branch: ${env.BRANCH_NAME ?: env.GIT_BRANCH}"
            }
        }

        // ── BACKEND ──
        stage('Backend – Install') {
            steps { dir('backend') { bat 'pip install -r requirements.txt' } }
        }
        stage('Backend – Lint') {
            steps { dir('backend') { bat 'flake8 . --count --select=E9,F63,F7,F82 --show-source' } }
        }
        stage('Backend – Test') {
            steps { dir('backend') { bat 'python -m pytest tests/ --junitxml=test-results.xml -v' } }
            post { always { junit allowEmptyResults: true, testResults: 'backend/test-results.xml' } }
        }

        // ── FRONTEND ──
        stage('Frontend – Get Deps') {
            steps { dir('frontend') { bat 'flutter pub get' } }
        }
        stage('Frontend – Analyze') {
            steps { dir('frontend') { bat 'flutter analyze' } }
        }
        stage('Frontend – Test') {
            steps { dir('frontend') { bat 'flutter test --machine > test-results.json' } }
        }
        stage('Frontend – Build APK') {
            when { anyOf { branch 'main'; branch 'release/*' } }
            steps { dir('frontend') { bat 'flutter build apk --release' } }
            post { success { archiveArtifacts artifacts: 'frontend/build/app/outputs/flutter-apk/*.apk' } }
        }
    }

    post {
        success { echo '✅ Pipeline completed!' }
        failure { echo '❌ Pipeline failed.' }
        cleanup { cleanWs() }
    }
}
```

### 5.3 GitHub Actions (Supplementary CI)

**Backend CI** (`.github/workflows/backend-ci.yml`):
- Trigger: Push/PR to `develop`, `main`, `feature/*`
- Steps: Python setup → Install deps → Lint → Test → Coverage report

**Frontend CI** (`.github/workflows/frontend-ci.yml`):
- Trigger: Push/PR to `develop`, `main`, `feature/*`
- Steps: Flutter setup → Pub get → Analyze → Test → Build APK (main/release only)

---

## 6. Docker Deployment

### 6.1 Container Architecture

```
docker-compose.yml
├── backend     (FastAPI)        → Port 8000
├── postgres    (PostgreSQL 15)  → Port 5432
├── redis       (Redis 7)       → Port 6379
└── nginx       (Reverse Proxy)  → Port 80/443
```

### 6.2 docker-compose.yml Overview

```yaml
services:
  backend:
    build: ./backend
    ports: ["8000:8000"]
    depends_on: [postgres, redis]
    env_file: .env
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s

  postgres:
    image: postgres:15-alpine
    volumes: [pgdata:/var/lib/postgresql/data]
    environment:
      POSTGRES_DB: arogya_sathi
      POSTGRES_USER: arogya_user

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

  nginx:
    image: nginx:alpine
    ports: ["80:80", "443:443"]
    depends_on: [backend]
```

---

## 7. Environment Management

### 7.1 Environment Parity

| Aspect | Development | Staging | Production |
|--------|-------------|---------|------------|
| Backend | localhost:8000 | staging.api.aarogyasathi.com | api.aarogyasathi.com |
| Database | Docker PostgreSQL | Managed DB (small) | Managed DB (HA) |
| Redis | Docker Redis | Managed Redis | Redis Cluster |
| Gemini API | Same key (rate limited) | Same key | Production key |
| Logging | Console + file | JSON structured | JSON + monitoring |
| SSL | Self-signed | Let's Encrypt | Managed SSL |

### 7.2 Environment Variables (.env.example)

```bash
# Application
APP_ENV=development  # development | staging | production
APP_DEBUG=true
APP_PORT=8000

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/arogya_sathi
DATABASE_POOL_SIZE=10

# Redis
REDIS_URL=redis://localhost:6379/0

# Authentication
JWT_SECRET=your-256-bit-secret
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE=3600
JWT_REFRESH_TOKEN_EXPIRE=2592000

# Google APIs
GOOGLE_API_KEY=your-gemini-api-key
GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json

# External APIs
WAQI_API_KEY=your-waqi-key
OPENWEATHER_API_KEY=your-openweather-key

# CORS
CORS_ORIGINS=http://localhost:3000,https://aarogyasathi.com
```

---

## 8. Monitoring & Observability

### 8.1 Health Check Endpoints

| Endpoint | Purpose | Expected Response |
|----------|---------|------------------|
| `GET /health` | App liveness | `{"status": "healthy"}` |
| `GET /health/ready` | Readiness (DB + Redis connected) | `{"db": "ok", "redis": "ok"}` |
| `GET /metrics` | Prometheus metrics (future) | Prometheus format |

### 8.2 Logging Strategy

```
Structured JSON Logging:
{
    "timestamp": "2026-03-10T14:30:00Z",
    "level": "INFO",
    "service": "aarogya-sathi-api",
    "request_id": "req_abc123",
    "user_id": "user_xyz",
    "endpoint": "/api/v1/chat/message",
    "response_time_ms": 1250,
    "status_code": 200,
    "message": "Chat message processed successfully"
}

Log Levels:
  DEBUG   → Development only, verbose
  INFO    → Normal operations, request logs
  WARNING → Degraded performance, cache miss, fallback used
  ERROR   → Request failures, API errors
  CRITICAL→ System down, data corruption, safety filter bypass
```

### 8.3 Alerting Rules

| Condition | Severity | Action |
|-----------|----------|--------|
| API p95 > 5s | Warning | Slack notification |
| Error rate > 5% (5 min) | Critical | Page on-call |
| Safety filter bypass detected | Critical | Immediate page + disable endpoint |
| Gemini API down > 5 min | Warning | Auto-switch to fallback model |
| Database connection pool exhausted | Critical | Page + auto-scale |
| Subscription job failed | Warning | Slack notification + manual check |

---

## 9. Release Management

### 9.1 Versioning Strategy (SemVer)

```
v{MAJOR}.{MINOR}.{PATCH}

MAJOR → Breaking changes (API contract change)
MINOR → New features (backward compatible)
PATCH → Bug fixes, security patches

Examples:
  v1.0.0 → Initial MVP release
  v1.1.0 → Added voice input feature
  v1.1.1 → Fixed voice input crash on Android 12
  v2.0.0 → New API version (v2), breaking changes
```

### 9.2 Release Process

```
1. Feature freeze on develop branch
2. Create release/v1.x.x branch from develop
3. QA testing on staging environment
4. Fix bugs on release branch (if any)
5. Merge release → main (with tag)
6. Merge release → develop (back-merge)
7. Deploy main to production
8. Create GitHub Release with changelog
```

### 9.3 Rollback Plan

```
If production issue detected:
    │
    ├─ Severity: LOW → Hotfix branch → Patch release
    │
    ├─ Severity: MEDIUM → Revert last deployment
    │   ├─ Docker: docker-compose down && docker-compose up (previous tag)
    │   └─ DB: Check if migration needed → Alembic downgrade
    │
    └─ Severity: CRITICAL → Immediate rollback
        ├─ Revert to last known good Docker image tag
        ├─ Revert database migration if needed
        ├─ Notify all stakeholders
        └─ Post-mortem within 24 hours
```

---

## 10. Quality Gates

### 10.1 Pre-Merge Gates (PR to develop)

| Gate | Tool | Threshold |
|------|------|-----------|
| Lint (Backend) | flake8 | 0 errors (E9, F63, F7, F82) |
| Lint (Frontend) | dart analyze | 0 errors |
| Unit Tests | pytest / flutter_test | 100% passing |
| Code Coverage | pytest-cov | >80% |
| Security Scan | bandit (Python) | 0 high-severity |
| Medical Safety | Custom test suite | 0 violations |

### 10.2 Pre-Release Gates (PR to main)

| Gate | Threshold |
|------|-----------|
| All pre-merge gates passing | ✅ |
| Integration tests passing | 100% |
| Load test (<2s p95 at 1000 users) | ✅ |
| Medical safety (100 test cases) | 0 violations |
| Manual QA sign-off | ✅ |
| Medical advisory board review | ✅ (before v1.0.0) |

---

**Document Status:** ✅ Complete
**Version:** 3.0 | **Last Updated:** March 10, 2026
