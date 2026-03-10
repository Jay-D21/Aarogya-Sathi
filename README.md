# 🏥 Aarogya Sathi (आरोग्य साथी)

**AI-Powered Health Companion for Urban India**

[![Backend CI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)](backend/)
[![Frontend](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter)](frontend/)
[![AI](https://img.shields.io/badge/AI-Gemini%202.0-4285F4?logo=google)](https://ai.google.dev)
[![DB](https://img.shields.io/badge/Database-PostgreSQL%2015-4169E1?logo=postgresql)](https://postgresql.org)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-D24939?logo=jenkins)](devops/Jenkinsfile)

---

## 🚀 What is Aarogya Sathi?

Aarogya Sathi is a **mobile-first AI health assistant** that:

- 🗣️ **Speaks your language** — Hindi, Marathi, English (voice + text)
- 🌍 **Knows your environment** — Real-time AQI + weather integrated into health advice
- 📊 **Tracks your health** — Blood pressure, blood sugar, symptoms with trend visualization
- 📄 **Reads your reports** — OCR extracts biomarkers from medical reports and provides ICMR-guided interpretation
- 🛡️ **Never pretends to be a doctor** — Strict safety: zero diagnosis, zero prescriptions, mandatory disclaimers

> ⚠️ **Aarogya Sathi is a health awareness companion, NOT a diagnostic tool or replacement for professional medical care.**

---

## 🏗️ Architecture Overview

```
Flutter App (Android/iOS)
    │
    ├── SQLite (offline health data)
    │
    ▼  HTTPS / REST API
FastAPI Backend
    │
    ├── PostgreSQL 15 (15 tables, 40+ indexes)
    ├── Redis (caching, sessions, rate limiting)
    │
    ├── Google Gemini 2.0 Flash (AI chat)
    ├── WAQI API (AQI) + OpenWeatherMap (weather)
    ├── Google Cloud Vision (OCR)
    └── Google Cloud Speech/TTS (voice I/O)
```

---

## 📁 Project Structure

```
Aarogya Sathi/
├── docs/                                # 📘 Project documentation
│   ├── AAROGYA_SATHI_PRD_v3_PRIVATE.md  #   Product Requirements Document
│   ├── PROJECT_DESIGN_REPORT.md         #   PDR (architecture, DFDs, UML)
│   ├── DATABASE_ADVANCED_DBMS.md        #   ER, EER, PL/SQL, triggers
│   ├── TECH_WORKFLOW.md                 #   Tech workflow & data flows
│   └── DEVOPS_SDLC_AGILE.md            #   Sprints, CI/CD, Agile process
│
├── research/                            # 📚 Original research & prep files
│   ├── AROGYA_SATHI_MVP_PRD_GEMINI_API.md
│   ├── GEMINI_SYSTEM_PROMPT_740_LINES.md
│   ├── AROGYA_SATHI_IMPLEMENTATION_GUIDE.md
│   ├── DATABASE_SCHEMA_COMPLETE.md
│   ├── API_SPECIFICATION_COMPLETE.md
│   ├── COMPLETE_PACKAGE_v2.0_SUMMARY.md
│   ├── AROGYA_SATHI_MVP_COMPLETE_SUMMARY.md
│   ├── QUICK_REFERENCE.md
│   ├── FINAL_CHECKLIST_ACTION_ITEMS.md
│   └── ... (more research files)
│
├── devops/                              # ⚙️ CI/CD & deployment configs
│   ├── Jenkinsfile                      #   Jenkins pipeline
│   ├── Dockerfile.backend               #   Backend container
│   ├── Dockerfile.frontend              #   Frontend container
│   ├── docker-compose.yml               #   Full-stack orchestration
│   ├── .env.example                     #   Environment variable template
│   └── github-actions/                  #   GitHub Actions workflows
│       ├── backend-ci.yml
│       └── frontend-ci.yml
│
├── backend/                             # 🐍 FastAPI backend (to be built)
├── frontend/                            # 📱 Flutter app (to be built)
│
├── .gitignore
└── README.md                            # ← You are here
```

---

## ⚡ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile app |
| **Backend** | Python FastAPI | Async REST API server |
| **AI Engine** | Google Gemini 2.0 Flash | Health chat with 700+ line system prompt |
| **Primary DB** | PostgreSQL 15+ | 15 tables, ACID, JSONB, RLS |
| **Local DB** | SQLite | Offline-first mobile storage |
| **Cache** | Redis 7 | Sessions, rate limiting, API caching |
| **OCR** | Google Cloud Vision | Medical report text extraction |
| **Voice** | Google Cloud Speech/TTS | Hindi, Marathi, English voice I/O |
| **AQI** | WAQI API | Real-time air quality data |
| **Weather** | OpenWeatherMap | Temperature, humidity, conditions |
| **CI/CD** | Jenkins + GitHub Actions | Automated lint, test, build, deploy |
| **Containers** | Docker + docker-compose | PostgreSQL, Redis, Nginx, Backend |

---

## 🌿 Branch Strategy (GitFlow)

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready, stable releases |
| `develop` | Integration branch for features |
| `feature/*` | Individual feature branches |
| `bugfix/*` | Bug fix branches |
| `release/*` | Release preparation |
| `hotfix/*` | Critical production fixes |

---

## 🛠️ Getting Started

### Prerequisites

- Python 3.11+
- Flutter SDK 3.19+
- PostgreSQL 15+ (or Docker)
- Redis 7+ (or Docker)
- Google Cloud API keys (Gemini, Vision, Speech, TTS)
- WAQI API key
- OpenWeatherMap API key

### Quick Start (Docker)

```bash
# 1. Clone the repo
git clone https://github.com/Jay-D21/Aarogya-Sathi.git
cd Aarogya-Sathi

# 2. Copy and configure environment
cp devops/.env.example devops/.env
# Edit devops/.env with your API keys

# 3. Start all services
cd devops && docker-compose up -d

# 4. API available at http://localhost:8000
# 5. Health check: http://localhost:8000/health
```

### Manual Setup

```bash
# Backend
cd backend
python -m venv venv && source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# Frontend
cd frontend
flutter pub get
flutter run
```

---

## 📊 Key Metrics

| Metric | Target |
|--------|--------|
| API Response Time (p95) | < 2 seconds |
| App Crash Rate | < 0.1% |
| Uptime | 99.5%+ |
| Medical Safety (diagnosis claims) | 0 in 100 test cases |
| Medical Safety (Rx claims) | 0 in 100 test cases |
| Disclaimer Presence | 100% of responses |

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [PRD v3](docs/AAROGYA_SATHI_PRD_v3_PRIVATE.md) | Product Requirements Document |
| [Project Design Report](docs/PROJECT_DESIGN_REPORT.md) | Architecture, DFDs, UML, cost analysis |
| [Advanced DBMS](docs/DATABASE_ADVANCED_DBMS.md) | ER/EER, PL/SQL, triggers, cursors, indexes |
| [Tech Workflow](docs/TECH_WORKFLOW.md) | End-to-end data flows, caching, error handling |
| [DevOps & Agile](docs/DEVOPS_SDLC_AGILE.md) | Sprints, CI/CD, Git workflow, release management |

---

## 📜 License

This project is proprietary. All rights reserved.

---

**Built with ❤️ for India's health**
