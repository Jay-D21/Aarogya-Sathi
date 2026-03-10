# AAROGYA SATHI — Product Requirements Document
## AI-Powered Health Companion for Urban India

**Date:** February 19, 2026
**Status:** Ready for Development
**Team:** Independent Development Team
**Timeline:** 6 Weeks to MVP

---

## 1. THE PROBLEM

India's urban population faces a unique health crisis at the intersection of three forces:

1. **Environmental Degradation** — Delhi's AQI regularly crosses 400+. Mumbai, Pune, Chennai face seasonal pollution spikes. There is no tool that connects air quality to personal health advice in real time.

2. **Healthcare Access Gap** — A basic doctor visit costs ₹500–₹1,500. For the 60%+ urban population earning under ₹50K/month, this means most health questions go unanswered. People turn to Google, WhatsApp forwards, or ignore symptoms entirely.

3. **Language Barrier** — India's digital health tools are English-first. But 75%+ of urban Indians think, speak, and search in Hindi, Marathi, Tamil, or Telugu. A mother in Nagpur worried about her child's cough during pollution season has no tool that speaks her language and understands her environment.

**The result:** Preventable conditions like diabetes, hypertension, and respiratory illness escalate because people lack timely, affordable, culturally relevant health guidance.

---

## 2. THE SOLUTION — AAROGYA SATHI

Aarogya Sathi (आरोग्य साथी — "Health Companion") is a **mobile-first AI health assistant** that:

- **Speaks your language** — Hindi, Marathi, English (MVP); more languages post-launch
- **Knows your environment** — Real-time AQI, temperature, humidity, and weather alerts for your city
- **Tracks your health** — Blood pressure, blood sugar, symptoms, weight, sleep, exercise
- **Reads your reports** — Photograph a blood test report; AI extracts biomarkers and explains them
- **Follows medical guidelines** — Every response is grounded in ICMR (Indian Council of Medical Research) guidelines
- **Never pretends to be a doctor** — Strict safety boundaries: no diagnosis, no prescriptions, always recommends professional consultation

### What Aarogya Sathi is NOT

| ❌ NOT This | ✅ BUT This |
|------------|------------|
| A diagnostic tool | A health awareness companion |
| A prescription service | A guideline-based information source |
| A replacement for doctors | A bridge between symptoms and professional care |
| A government health portal | An independent product, open to partnerships |
| A chatbot with generic answers | A context-aware AI that knows your city's AQI, your BP history, and your language |

---

## 3. WHO IS THIS FOR

### Primary User: The Urban Indian Health-Conscious Individual

**Demographics:**
- Age: 25–55 years
- Location: Tier 1 & Tier 2 Indian cities (Delhi, Mumbai, Pune, Bangalore, Chennai, Hyderabad, Nagpur, Jaipur, Lucknow)
- Income: ₹20K–₹1L/month
- Smartphone: Android (85%+), some iOS
- Languages: Hindi, Marathi, English

**User Personas:**

| Persona | Profile | Primary Need |
|---------|---------|-------------|
| **Priya (28)** | IT professional, Delhi | Daily AQI alerts, stress management, health tracking |
| **Ramesh (52)** | Small business owner, Pune | Diabetes management, BP tracking, Marathi-language support |
| **Sunita (35)** | Homemaker, Mumbai | Family health guidance, report understanding, voice input (Hindi) |
| **Arjun (40)** | Factory supervisor, Nagpur | Pollution-related respiratory guidance, affordable health info |

### Secondary User: Corporate HR / Wellness Managers

- Companies with 500–10,000 employees
- Need: Employee wellness dashboards, preventive health programs, ROI tracking on healthcare spend
- Budget: ₹10–50 Lakhs/year for wellness solutions

---

## 4. CORE FEATURES — DETAILED SPECIFICATIONS

### Feature 1: Multilingual Health Chat

**Priority:** P0 (Critical — this IS the product)

The conversational AI interface where users ask health questions and receive guideline-based, environment-aware responses.

**How it works:**

```
User speaks (Marathi): "Mala sardi ahe aur dokyala dukhtay"
    ↓
Speech-to-text (Google Cloud Speech) → Marathi text
    ↓
Backend fetches:
  - User's city AQI (WAQI API): Pune, AQI 185 (Moderate)
  - User's health history: Pre-diabetic, mild hypertension
  - User's recent symptoms: None in past 7 days
    ↓
Context + System Prompt + User Query → Gemini API
    ↓
Safety validation (no diagnosis/prescription in response)
    ↓
Response displayed in Marathi with optional voice playback (TTS)
```

**Technical Specifications:**

| Parameter | Value |
|-----------|-------|
| AI Model | Google Gemini 2.0 Flash (primary) |
| Fallback Model | Gemini 1.5 Flash Lite |
| System Prompt | 700+ lines covering safety, ICMR guidelines, environmental context |
| Temperature | 0.3 (low — for medical accuracy and consistency) |
| Max Output Tokens | 1,000 per response |
| Response Timeout | 10 seconds |
| Languages | Hindi, Marathi, English |
| Input Methods | Text typing + Voice (speech-to-text) |
| Output Methods | Text display + Voice (text-to-speech, optional) |

**The System Prompt — The Soul of Aarogya Sathi:**

The system prompt is a 700+ line document that defines every aspect of how the AI behaves. It is NOT a simple "You are a health assistant" instruction. It is a comprehensive behavioral framework:

| Section | Purpose | Example Rule |
|---------|---------|-------------|
| Identity & Boundaries | Defines role as awareness assistant | "You are NOT a doctor. You CANNOT diagnose." |
| Diagnosis Prohibition | Blocks all diagnostic claims | Never say "You have diabetes" — instead "Your readings suggest elevated blood sugar; please consult a doctor" |
| Prescription Prohibition | Blocks all medication advice | Never say "Take Metformin 500mg" — instead "Your doctor may consider medications based on your reports" |
| Emergency Detection | Identifies 108-worthy emergencies | Chest pain + sweating + jaw pain → Immediate: "Call 108 NOW. This could be a cardiac emergency." |
| ICMR Guidelines | Embedded medical reference data | Fasting glucose 100-125 = pre-diabetic (ICMR 2020); BP >140/90 = Stage 1 hypertension |
| Environmental Context | How to weave AQI/weather into advice | If AQI >200: "Current air quality is poor. If you have respiratory symptoms, stay indoors and use a mask" |
| Vernacular Sensitivity | Cultural and linguistic nuances | Understand "gas" = acidity (not flatulence); "body heat" = pitta concept; respect Ayurvedic references without endorsing unproven claims |
| Mandatory Disclaimers | Every response includes a disclaimer | "⚠️ Yeh jaankari sirf samajhne ke liye hai. Kripya doctor se zaroor milein." |
| Privacy | Never ask for or store Aadhaar, insurance, etc. | Only collect health-relevant data with explicit consent |

**Safety Validation Pipeline (Backend):**

After Gemini generates a response, the backend runs it through a safety filter before showing it to the user:

```python
# Patterns that MUST NOT appear in any response
BLOCKED_PATTERNS = [
    "you have [disease]",
    "diagnosis is",
    "take [medication] [dose]",
    "prescription",
    "you are suffering from",
    "I can confirm that you have"
]

# Patterns that MUST appear in every response
REQUIRED_PATTERNS = [
    "disclaimer" or "consult" or "doctor" or "professional"
]
```

If a response fails safety validation, a safe fallback response is returned instead.

---

### Feature 2: Real-Time Environmental Awareness

**Priority:** P0 (Critical — key differentiator)

Every health conversation and recommendation is enriched with the user's real-time environmental data. This is what makes Aarogya Sathi different from every other health chatbot.

**Data Sources:**

| Source | API | Free Tier | Data Provided |
|--------|-----|-----------|---------------|
| Air Quality | WAQI (waqi.info) | 10,000 calls/day | AQI, PM2.5, PM10, NO₂, SO₂ |
| Weather | OpenWeatherMap | 1,000 calls/day | Temperature, humidity, wind, conditions |

**Alert System:**

| Trigger | Threshold | User Action |
|---------|-----------|-------------|
| AQI Spike | >300 (Severe) | Push notification: "Stay indoors. Use N95 mask if going outside. Increase water intake." |
| Heatwave | >40°C for 2+ consecutive days | "Avoid outdoor activity 11am-3pm. Drink 3+ liters water. Watch for heat exhaustion signs." |
| Cold Wave | <5°C for 2+ consecutive days | "Layer clothing. Increase warm fluid intake. Vitamin C-rich foods recommended (ICMR)." |
| Monsoon Risk | Heavy rainfall alerts | "Boil drinking water. Avoid street food. Watch for waterborne disease symptoms." |
| High Pollen | Pollen count elevated | "If you have respiratory conditions, minimize outdoor exposure. Keep windows closed." |

**How environmental data flows into chat:**

When a user asks "I have a cough that won't go away", the AI response will include:

> *"A persistent cough can have many causes. I notice your city (Delhi) currently has AQI 320 (Severe). High air pollution is a common cause of persistent cough, especially in people with existing respiratory sensitivity.*
>
> *ICMR recommends: Stay indoors during high AQI, use an N95 mask if going outside, and consider using an air purifier at home.*
>
> *If your cough has lasted more than 2 weeks, is accompanied by blood, or you have difficulty breathing, please consult a pulmonologist immediately.*
>
> *⚠️ This is general health awareness information. Please consult a doctor for proper evaluation."*

---

### Feature 3: Health Tracking & History

**Priority:** P0 (Critical)

Users log daily health metrics. The app stores this data, shows trends, and feeds it to the AI for personalized responses.

**Tracked Metrics:**

| Category | Metrics | Input Method |
|----------|---------|-------------|
| **Cardiovascular** | Blood pressure (systolic/diastolic), heart rate | Manual entry |
| **Metabolic** | Blood sugar (fasting, random, post-prandial), weight, height, BMI | Manual entry |
| **Respiratory** | Symptom log (cough, breathlessness, wheeze) | Checklist + notes |
| **Lifestyle** | Sleep hours + quality, exercise type + duration, water intake, stress level | Manual entry |
| **Dietary** | Food items consumed, alcohol units, smoking status | Manual entry |
| **Medication** | Medications taken, adherence tracking | Manual entry |

**Data Storage Strategy:**

```
┌─────────────────┐     Auto-sync when online     ┌─────────────────┐
│   SQLite (Local) │ ──────────────────────────── → │ PostgreSQL      │
│   On user's phone│ ← ──────────────────────────── │ (Cloud server)  │
│   Works offline  │                                │ Primary source  │
└─────────────────┘                                └─────────────────┘
```

- **Offline-first:** User can log data without internet. Syncs automatically when online.
- **Privacy:** Health data is encrypted at rest. No PII (name, email, phone) is ever sent to Gemini API — only anonymized health context.

**Trend Visualization:**
- Line charts for BP and blood sugar over time (7/30/90 day views)
- Daily/weekly summary cards
- Abnormal reading alerts (e.g., BP >140/90 triggers a warning)
- ICMR reference ranges shown alongside user data

---

### Feature 4: Medical Report OCR & Analysis

**Priority:** P1 (High)

Users photograph blood test reports. The system extracts values and provides ICMR-guided interpretation.

**Processing Pipeline:**

```
User photographs blood test report (JPG/PNG)
    ↓
Image uploaded to server (encrypted)
    ↓
Google Cloud Vision API → Full text extraction (OCR)
    ↓
Gemini API parses text → Structured biomarker JSON
    {glucose: 125, HbA1c: 7.2, cholesterol: 220, ...}
    ↓
Compare each value against ICMR normal ranges
    ↓
Generate interpretation (awareness only, no diagnosis)
    ↓
Display to user with highlighted abnormal values
```

**Biomarkers Extracted:**

| Category | Markers |
|----------|---------|
| **Diabetes** | Fasting glucose, random glucose, post-prandial glucose, HbA1c |
| **Lipid Profile** | Total cholesterol, HDL, LDL, triglycerides, VLDL |
| **Kidney** | Creatinine, BUN, uric acid |
| **Liver** | SGOT, SGPT, bilirubin |
| **Blood Count** | Hemoglobin, platelet count, WBC, RBC |
| **Thyroid** | TSH, T3, T4 |

**Example Output:**

> **Report Analysis (Blood Test - Jan 7, 2026)**
>
> | Marker | Your Value | Normal Range (ICMR) | Status |
> |--------|-----------|---------------------|--------|
> | Fasting Glucose | 125 mg/dL | 70–100 mg/dL | ⚠️ Elevated |
> | HbA1c | 7.2% | <5.7% | ⚠️ Elevated |
> | Total Cholesterol | 220 mg/dL | <200 mg/dL | ⚠️ Borderline |
>
> *Your fasting glucose and HbA1c suggest elevated blood sugar levels. ICMR guidelines classify fasting glucose 100-125 as pre-diabetic range. Please consult an endocrinologist for further evaluation.*
>
> *⚠️ This is an AI-generated interpretation for awareness only. It is NOT a medical diagnosis.*

---

### Feature 5: Voice Input & Output

**Priority:** P1 (High)

Critical for Hindi/Marathi-first users who are more comfortable speaking than typing.

| Component | Technology | Languages |
|-----------|-----------|-----------|
| Speech-to-Text | Google Cloud Speech API | Hindi, Marathi, English |
| Text-to-Speech | Google Cloud TTS | Hindi, Marathi, English |

**User Experience:**
- Tap microphone icon → speak in any supported language
- AI response displayed as text AND optionally read aloud
- Voice speed, language, and gender configurable in settings

---

### Feature 6: Proactive Health Recommendations

**Priority:** P1 (High)

Daily personalized tips based on the intersection of: health history + environmental conditions + ICMR guidelines.

**Example (morning notification for a pre-diabetic user in Delhi):**

> *"Good morning, Ramesh! 🌅*
>
> *Delhi AQI today: 280 (Poor). Temperature: 32°C.*
>
> *For your health profile:*
> - *Walk indoors today — outdoor air quality is unsafe*
> - *Low-GI breakfast recommended: oats, dalia, or moong dal chilla (avoid white bread, poha with sugar)*
> - *Target: 8 glasses water today (pollution + pre-diabetes = higher dehydration risk)*
> - *Check your fasting sugar this morning — last reading was 5 days ago*
>
> *ICMR says: 150 minutes/week of moderate exercise + dietary changes can delay diabetes onset by 58%."*

---

## 5. TECHNICAL ARCHITECTURE

### 5.1 Technology Stack

| Layer | Technology | Why This Choice |
|-------|-----------|----------------|
| **Mobile App** | Flutter (Dart) | Single codebase for Android + iOS; offline-capable with SQLite |
| **Backend API** | Python FastAPI | Async, high-performance; natural fit for Gemini + Google Cloud SDKs |
| **AI Engine** | Google Gemini API (Flash 2.0) | No custom training needed; pay-per-use; 700+ line system prompt handles all medical logic |
| **Primary Database** | PostgreSQL 15+ | ACID-compliant, JSON support, production-grade |
| **Local Database** | SQLite | Offline health data storage on device; auto-syncs to PostgreSQL |
| **Cache** | Redis | API response caching, session management, rate limiting |
| **Authentication** | JWT (python-jose + passlib) | Lightweight; no external auth dependency for MVP |
| **OCR** | Google Cloud Vision API | Accurate text extraction from medical report images |
| **Speech-to-Text** | Google Cloud Speech API | Hindi, Marathi, English support |
| **Text-to-Speech** | Google Cloud TTS | Natural-sounding voice output |
| **AQI Data** | WAQI API | Real-time air quality for Indian cities |
| **Weather Data** | OpenWeatherMap API | Temperature, humidity, conditions |
| **CI/CD** | Jenkins | Pipeline already configured in `Jenkinsfile` |
| **Version Control** | Git + GitHub | Feature branch workflow |

### 5.2 System Architecture Diagram

```
┌───────────────────────────────────────────────────┐
│            MOBILE APP (Flutter)                    │
│  ┌──────┐ ┌──────┐ ┌────────┐ ┌───────────────┐  │
│  │ Chat │ │Voice │ │Health  │ │Report Upload  │  │
│  │Screen│ │Input │ │Tracker │ │(Camera/Gallery)│  │
│  └──┬───┘ └──┬───┘ └───┬────┘ └───────┬───────┘  │
│     └────────┴─────────┴───────────────┘          │
│                    │                               │
│              SQLite (offline)                      │
└────────────────────┼──────────────────────────────┘
                     │ HTTPS / REST API
┌────────────────────▼──────────────────────────────┐
│              FastAPI BACKEND                       │
│                                                    │
│  ┌────────────────────────────────────────────┐   │
│  │ Middleware: Auth │ Rate Limit │ Validation  │   │
│  └────────────────────────────────────────────┘   │
│                                                    │
│  ┌─────────── ROUTE HANDLERS ────────────────┐   │
│  │ /auth  │ /chat  │ /health │ /reports      │   │
│  │ /environment │ /analytics │ /feedback     │   │
│  └───────────────────────────────────────────┘   │
│                                                    │
│  ┌─────────── SERVICES ──────────────────────┐   │
│  │ GeminiService │ HealthService │ OCRService │   │
│  │ EnvironmentService │ SafetyService        │   │
│  │ AuthService │ CacheService                │   │
│  └───────────────────────────────────────────┘   │
└──────┬──────────────┬──────────────┬─────────────┘
       │              │              │
┌──────▼──────┐ ┌─────▼──────┐ ┌────▼────────┐
│ Gemini API  │ │ PostgreSQL │ │ Redis       │
│ (700+ line  │ │ (15 tables)│ │ (cache +    │
│  sys prompt)│ │            │ │  sessions)  │
└──────┬──────┘ └────────────┘ └─────────────┘
       │
┌──────▼──────────────────────┐
│ External APIs               │
│ WAQI │ OpenWeather │ Vision │
│ Cloud Speech │ Cloud TTS    │
└─────────────────────────────┘
```

### 5.3 Database Schema — 15 Tables

| # | Table | Key Columns | Purpose |
|---|-------|-------------|---------|
| 1 | **users** | id, email, phone, password_hash, preferred_language, preferred_city, subscription_plan, consent flags | User accounts and preferences |
| 2 | **health_records** | user_id, record_type, BP values, sugar values, weight, sleep, stress, exercise, environmental_context (JSON) | All health data entries |
| 3 | **chat_history** | user_id, user_message, ai_response, model_used, tokens_used, language, safety flags | Chat logs with AI metadata |
| 4 | **medical_reports** | user_id, report_type, biomarkers (JSON), extracted_text, interpretation, abnormal_values, OCR confidence | Uploaded reports + analysis |
| 5 | **environmental_alerts** | user_id, alert_type, severity, aqi_value, temperature, health_conditions_affected, recommendations | Proactive environment alerts |
| 6 | **health_conditions** | user_id, condition_name, category, status, severity, medications, monitoring_frequency, doctor info | Chronic condition tracking |
| 7 | **user_preferences** | user_id, notification settings, voice settings, privacy settings, dietary/exercise preferences | All user settings |
| 8 | **auth_sessions** | user_id, access_token, refresh_token, device_type, device_name, expires_at | JWT session management |
| 9 | **subscriptions** | user_id, plan_type, billing_amount, billing_cycle, payment_method, features_included (JSON) | Subscription & billing |
| 10 | **user_analytics** | user_id, date, messages_sent, reports_uploaded, session_count, feature_usage (JSON) | Usage tracking |
| 11 | **api_usage** | user_id, endpoint, model_used, input_tokens, output_tokens, estimated_cost | API cost tracking |
| 12 | **user_feedback** | user_id, feedback_type, rating, description, status | Bug reports & feedback |
| 13 | **corporate_accounts** | company_name, employee_count, contract_value, assigned_licenses, api_keys | B2B company accounts |
| 14 | **corporate_employee_mapping** | corporate_id, user_id, employee_id, department, data_sharing_permission | Corporate ↔ user link |
| 15 | **abdm_integrations** | user_id, abha_number, consent_status, tokens | Future ABDM/ABHA support |

### 5.4 API Endpoints — 25 for MVP

**Authentication (5):**
`POST /register` · `POST /login` · `POST /refresh-token` · `POST /logout` · `POST /verify`

**Chat (5):**
`POST /message` · `POST /voice` · `GET /history` · `POST /{id}/rate` · `GET /search`

**Health Tracking (5):**
`POST /bp-reading` · `POST /sugar-reading` · `POST /symptom-log` · `GET /records` · `GET /trends`

**Medical Reports (3):**
`POST /upload` · `GET /list` · `GET /{id}`

**Environment (2):**
`GET /alerts` · `GET /current`

**Analytics (2):**
`GET /dashboard` · `GET /report`

**Feedback (1):**
`POST /submit`

**User Profile (2):**
`GET /profile` · `PUT /profile`

All endpoints are prefixed with `/api/v1/` and require JWT authentication (except register/login).

---

## 6. SAFETY & COMPLIANCE

### 6.1 Medical Safety — Non-Negotiable Rules

These rules are enforced at TWO levels: in the Gemini system prompt AND in the backend safety service.

| Rule | What It Means | Example |
|------|--------------|---------|
| **No Diagnosis** | AI never tells a user they have a disease | ❌ "You have diabetes" → ✅ "Your readings are in the pre-diabetic range per ICMR guidelines. Please consult a doctor." |
| **No Prescriptions** | AI never recommends specific medications or dosages | ❌ "Take Metformin 500mg twice daily" → ✅ "Your doctor may discuss medication options based on your reports." |
| **No Treatment Plans** | AI suggests lifestyle as complementary, not replacement | ❌ "You don't need a doctor, just exercise" → ✅ "Regular exercise is recommended alongside your doctor's treatment plan." |
| **Emergency Redirect** | Detect life-threatening symptoms → immediate 108 redirect | Chest pain + sweating → "🚨 Call 108 immediately. These symptoms require emergency medical attention." |
| **Mandatory Disclaimer** | Every single response includes a disclaimer | "⚠️ This information is for awareness only. Please consult a qualified healthcare professional." |

### 6.2 Privacy & Data Protection

- **DPDP Act (India) Compliant:** User owns all data; deletion within 30 days on request
- **No PII to Gemini:** Only anonymized health context sent to AI (no name, email, phone, Aadhaar)
- **Encryption:** Health data encrypted at rest (AES-256) and in transit (TLS 1.3)
- **Consent:** Explicit opt-in for data collection, notifications, and any data sharing
- **Data Minimization:** Only collect what's needed for the service to function

### 6.3 Legal Protection

- Medical advisory board review of system prompt and safety rules
- Liability insurance (₹2-5 Lakhs/year recommended)
- Clear Terms of Service: "This is not a medical device or diagnostic service"
- App store compliance for health category

---

## 7. MONETIZATION

### 7.1 Consumer (B2C)

| Tier | Price | Includes |
|------|-------|----------|
| **Free** | ₹0 | 5 AI chats/day, basic health tracking, environmental alerts |
| **Premium** | ₹99/month or ₹999/year | Unlimited chats, medical report OCR, full health trends, voice I/O, priority responses, ad-free |

### 7.2 Corporate Wellness (B2B)

| Tier | Price Range | Includes |
|------|-------------|----------|
| **Starter** | ₹10-25L/year | Up to 500 employees, wellness dashboard, quarterly reports |
| **Enterprise** | ₹25-100L/year | Unlimited employees, custom integrations, dedicated support, SLA |

### 7.3 Revenue Projections (Year 1)

| Source | Conservative | Optimistic |
|--------|-------------|-----------|
| Free Users | 50K–100K | 200K–500K |
| Premium Conversion | 5% | 10% |
| Consumer Revenue | ₹3–10L | ₹20–50L |
| Corporate Contracts | 3–5 | 10–20 |
| B2B Revenue | ₹30–125L | ₹100–400L |
| **Total Year 1** | **₹33–135L** | **₹120–450L** |

---

## 8. DEVELOPMENT TIMELINE — 6 WEEKS

| Week | Phase | What Gets Built |
|------|-------|----------------|
| **1** | Backend Foundation | FastAPI project structure, PostgreSQL schema + migrations, JWT auth, basic Gemini chat endpoint |
| **2** | Health + Frontend Shell | Health tracking CRUD APIs, Flutter app shell (login, home, chat screens), API integration |
| **3** | Environmental + Context | WAQI + OpenWeather integration, AQI alerts, environmental context injection into Gemini responses |
| **4** | Voice + Reports | Speech-to-text, TTS, medical report upload, Cloud Vision OCR, biomarker extraction |
| **5** | Polish + Testing | UI refinement, 50+ automated tests, safety validation testing, performance optimization, security audit |
| **6** | Beta Launch | Google Play beta, 100+ testers, feedback collection, iteration |

---

## 9. PROJECT STRUCTURE

```
aarogya-sathi/
├── backend/
│   ├── app/
│   │   ├── main.py                  # FastAPI entry point
│   │   ├── config.py                # Environment configuration
│   │   ├── dependencies.py          # Dependency injection
│   │   ├── routes/                  # API route handlers
│   │   │   ├── auth.py, chat.py, health.py, reports.py
│   │   │   ├── environment.py, analytics.py, feedback.py
│   │   ├── models/                  # SQLAlchemy ORM models
│   │   ├── schemas/                 # Pydantic request/response schemas
│   │   ├── services/                # Business logic
│   │   │   ├── gemini_service.py    # Gemini API wrapper + system prompt
│   │   │   ├── safety_service.py    # Response validation
│   │   │   ├── environment_service.py # AQI + Weather fetching
│   │   │   ├── ocr_service.py       # Report image processing
│   │   │   ├── auth_service.py      # JWT + password hashing
│   │   │   └── cache_service.py     # Redis caching
│   │   ├── utils/                   # Logging, validation, constants
│   │   └── db/                      # Database connection + sessions
│   ├── tests/                       # pytest test suite
│   ├── migrations/                  # Alembic DB migrations
│   ├── requirements.txt
│   └── .env.example
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/                 # UI screens (auth, chat, health, reports, etc.)
│   │   ├── models/                  # Dart data models
│   │   ├── services/                # API client, local storage
│   │   ├── providers/               # Riverpod state management
│   │   └── widgets/                 # Reusable UI components
│   └── pubspec.yaml
├── Jenkinsfile                      # CI/CD pipeline
└── README.md
```

---

## 10. EXTERNAL SERVICES & COSTS

| Service | Purpose | Free Tier | Monthly Cost at Scale |
|---------|---------|-----------|----------------------|
| Google Gemini API | AI chat responses | 15 req/min, 1.5M tokens/day | ₹2K–8K |
| WAQI | Air quality data | 10K calls/day | Free |
| OpenWeatherMap | Weather data | 1K calls/day | ₹500 |
| Google Cloud Vision | Report OCR | 1K reqs/month | ₹120/1K reqs |
| Google Cloud Speech | Voice input | 60 min/month | ₹500–2K |
| Google Cloud TTS | Voice output | 4M chars/month | ₹300–1K |
| PostgreSQL (Cloud) | Database | Dev: free (local) | ₹2K–5K |
| Redis (Cloud) | Caching | Dev: free (local) | ₹1K–3K |

**Total infrastructure cost at MVP scale (1K users): ₹5K–15K/month**

---

## 11. SUCCESS METRICS

### Technical Health
- API response time: <2 seconds (p95)
- App crash rate: <0.1%
- Uptime: 99.5%+
- Offline data sync: works reliably

### Medical Safety (100 test cases each)
- Diagnosis claims: 0
- Prescription claims: 0
- Disclaimer present: 100%
- Emergency detection accuracy: 95%+

### Business (Month 1-3)
- Downloads: 10K+ (Month 1), 50K+ (Month 3)
- Daily Active Users: 20%+ of installs
- Premium conversion: 3-5%
- Day-30 retention: 30%+
- Average session time: 3+ minutes

---

## 12. RISKS & HOW WE HANDLE THEM

| Risk | Impact | Mitigation |
|------|--------|------------|
| Medical liability (user follows AI advice and something goes wrong) | HIGH | Medical advisory board review, mandatory disclaimers, liability insurance, clear ToS |
| Gemini API costs escalate with scale | MEDIUM | Redis caching (cache environmental data 1hr, health context 24hr), rate limiting, Flash Lite fallback for simple queries |
| User privacy breach | HIGH | DPDP compliance, E2E encryption, no PII to Gemini, regular security audits |
| Low user retention | MEDIUM | Proactive daily notifications, environmental alerts, gamification of health tracking |
| Competition from established players | MEDIUM | Environmental awareness is our unique differentiator; no competitor combines AQI + health + vernacular AI |
| Gemini API downtime | LOW | Fallback to Flash Lite model; graceful degradation with cached responses |

---

## 13. FUTURE ROADMAP (POST-MVP)

| Timeline | Feature |
|----------|---------|
| Month 2-3 | Additional languages (Tamil, Telugu, Kannada), wearable integration (Fitbit, Apple Watch) |
| Month 4-6 | ABDM/ABHA health ID integration (if government APIs available), doctor directory & referral |
| Month 7-12 | Corporate wellness platform launch, hospital/clinic partnerships, insurance integrations |
| Year 2 | International expansion (Bangladesh, Sri Lanka), custom fine-tuned AI model exploration |

---

## 14. TEAM & GOVERNANCE

### Development Team
- Individual/independent team building this product
- Open to government partnerships and backing, but not dependent on them
- Decision-making is fast and internal — no bureaucratic approvals needed

### Advisory
- Medical advisory board recommended before beta launch
- Legal review of ToS and privacy policy before app store submission

---

**Document Status:** ✅ Complete — Ready for Development
**Next Action:** Begin Week 1 — Backend Foundation
