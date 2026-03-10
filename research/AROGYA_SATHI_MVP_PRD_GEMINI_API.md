# AROGYA SATHI v2.0 - MVP PRODUCT REQUIREMENTS DOCUMENT (PRD)
## Commercial Version with Google Gemini API Backend

**Version:** 1.0 MVP  
**Last Updated:** January 7, 2026  
**Status:** Ready for Development  
**Target Platform:** Any AI IDE (Claude, ChatGPT, etc.) for implementation  
**Backend:** Google Gemini API (Flash 2.0 / 1.5 Flash Lite)  
**Timeline:** 4-6 weeks MVP Development  

---

## 1. EXECUTIVE SUMMARY

### 1.1 Product Vision

**Arogya Sathi** is a commercial, environment-aware digital health assistant for urban India that uses **Google Gemini API** as the AI backbone with a comprehensive system prompt containing ICMR guidelines, healthcare AI standards, and safety requirements.

### 1.2 Key Changes from Original Plan

| Aspect | Original | MVP (New) |
|--------|----------|-----------|
| **AI Model** | Custom BioMistral-7B | Google Gemini API |
| **Model Choice** | Self-hosted inference | Flash 2.0 / 1.5 Flash Lite |
| **Go-to-Market** | Government partnerships | Commercial B2B + Consumer |
| **System Prompt** | N/A | 700+ line comprehensive prompt |
| **Development** | 12 months | 4-6 weeks MVP |
| **Infrastructure** | E2E Networks GPU | Google Cloud (Gemini) |
| **Timeline** | Phased | Fast MVP iteration |

### 1.3 MVP Scope (Phase 1 Only)

**In Scope:**
- ✅ Text-based health chat (Hindi, Marathi, English)
- ✅ Voice input (speech-to-text via Gemini/Whisper)
- ✅ Environment alerts (AQI + temperature context)
- ✅ Medical report OCR (basic biomarker extraction)
- ✅ Basic user authentication
- ✅ Health history storage (local + cloud sync)
- ✅ ABDM ABHA ID linking (MVP level)
- ✅ Analytics dashboard (basic health metrics)

**Out of Scope (Post-MVP):**
- ❌ Wearable integration
- ❌ Doctor booking/telemedicine
- ❌ Advanced medical diagnostics
- ❌ Hospital partnerships
- ❌ Insurance integrations

---

## 2. PRODUCT OVERVIEW

### 2.1 Target Users

#### Primary User: Urban Indian (Vernacular Speaker)
- **Age:** 25-55 years
- **Language:** Hindi, Marathi, Tamil, Telugu, Kannada
- **Income:** ₹20K-100K/month
- **Pain Point:** Can't afford ₹500-1000 consultations; needs preventive health guidance
- **Use Case:** Daily health tracking, environmental alerts, lifestyle advice

#### Secondary User: Corporate HR/Wellness Manager
- **Organization Size:** 500-10,000 employees
- **Pain Point:** Healthcare costs rising; need preventive program
- **Budget:** ₹10-50 Lakhs annually for wellness solution
- **Use Case:** Employee health tracking, wellness programs, cost reduction

#### Tertiary User: Healthcare Institution
- **Type:** Clinic, hospital, PHC
- **Pain Point:** Patient engagement, follow-up monitoring
- **Budget:** ₹50-500 Lakhs for health IT
- **Use Case:** Patient monitoring, preventive health program

### 2.2 Value Proposition

**For Consumers:** "Health guidance in your language, aware of your city's pollution, at ₹99/month"

**For Corporates:** "20-30% reduction in healthcare costs through preventive wellness"

**For Healthcare:** "Patient engagement platform that reduces follow-up burden on doctors"

---

## 3. CORE FEATURES (MVP)

### Feature 1: Multilingual Health Chat
**Priority:** P0 (Critical)

**Specification:**
- Input methods: Text + Voice
- Languages: Hindi, Marathi, English (MVP phase 1)
- Response format: Text + Optional audio (TTS via Google)
- Real-time translation via system prompt (no external APIs)

**User Flow:**
1. User speaks in Marathi: "Mujhe sardi ahe aur headache hai"
2. Whisper transcribes → "I have a cold and headache"
3. System prompt processes → "These symptoms + weather context"
4. Gemini responds: "Based on ICMR guidelines, cold with headache might be viral. Monitor for..."
5. Response translated back to Marathi (via system prompt logic)
6. TTS outputs in Marathi

**Gemini API Specifications:**
- Model: `gemini-2.0-flash` or `gemini-1.5-flash-latest`
- Temperature: 0.3 (lower = more deterministic for medical)
- Top-p: 0.9
- Max tokens: 1000 per response
- Timeout: 10 seconds

### Feature 2: Real-Time Environmental Context
**Priority:** P0 (Critical)

**Specification:**
- AQI data: WAQI API (free tier)
- Weather data: OpenWeatherMap (free tier)
- Temperature alerts: Real-time thresholds
- Integration: Via system prompt context injection

**Example Context:**
```
User location: Delhi
Current AQI: 350 (Severe)
Temperature: 42°C (Heatwave alert)
Humidity: 25%
Wind speed: 2 km/h (stagnant)

If respiratory symptom detected → Prioritize pollution advice
If any symptom + high temp → Heatwave protocol
```

**System Prompt Instruction:**
"If user mentions respiratory symptoms AND location is in severe AQI zone, ALWAYS include:
- N95 mask recommendation
- Stay indoors advice
- Air purifier tips
- Do NOT suggest outdoor exercise
- Do NOT suggest jogging or running
"

### Feature 3: Medical Report OCR
**Priority:** P1 (High)

**Specification:**
- Input: Photo of blood test report (JPG/PNG)
- Processing:
  1. Image cleanup (OpenCV)
  2. OCR text extraction (Tesseract or Cloud Vision)
  3. LLM parsing via Gemini (structured JSON)
  4. Biomarker validation

**Biomarkers Extracted:**
- Blood sugar (glucose, HbA1c)
- Lipid profile (total cholesterol, HDL, LDL)
- BP readings
- Creatinine (kidney function)
- Platelet count
- Hemoglobin

**System Prompt Instruction:**
"When user uploads medical report:
1. Extract all numerical values and units
2. Compare against ICMR normal ranges
3. Flag if values indicate pre-disease state
4. Suggest ICMR dietary modifications
5. Recommend follow-up timing
6. NEVER diagnose; always say 'Consult doctor for diagnosis'
"

### Feature 4: Health History & Tracking
**Priority:** P0 (Critical)

**Specification:**
- Data storage: PostgreSQL (cloud) + SQLite (local)
- Sync strategy: Real-time cloud sync when online
- Offline mode: Full functionality via SQLite
- Data retention: DPDP compliant (user owns data)

**Tracked Metrics:**
- Daily symptoms log (text)
- Blood pressure readings (systolic/diastolic)
- Blood sugar readings (fasting/random)
- Weight tracking
- Medication adherence
- Dietary notes
- Exercise/activity log
- Sleep quality
- Stress level

**Privacy:**
- End-to-end encrypted
- No PII sent to Gemini API
- User data never used for training
- Delete-on-request within 30 days

### Feature 5: ABDM ABHA Integration
**Priority:** P1 (High)

**Specification:**
- User can link ABHA ID (Ayushman Bharat)
- Read-only access to health records
- Share functionality (with consent)
- Interoperability with government systems

**Implementation:**
- OAuth flow for ABDM login
- Token refresh mechanism
- Privacy-preserving data share (zero-knowledge)

### Feature 6: Environmental Alerts
**Priority:** P0 (Critical)

**Specification:**
- Real-time AQI alerts (threshold: >300 = alert)
- Heatwave alerts (temperature >40°C for 2+ days)
- Cold wave alerts (temperature <5°C)
- Monsoon alerts (heavy rainfall)

**System Prompt Instruction:**
"Based on environmental triggers, suggest:
- AQI >300: Stay indoors, use N95 mask if outside
- Temperature >40°C: Increase water intake, avoid midday sun
- Monsoon/heavy rain: Avoid water-borne disease risk, consume boiled water
- Cold wave: Increase immunity (vitamin C, warm foods)
"

### Feature 7: Personalized Health Recommendations
**Priority:** P1 (High)

**Specification:**
- Based on: Health history, environmental data, ICMR guidelines
- Frequency: Daily tips (morning notification)
- Customization: By health condition (diabetes, hypertension, respiratory)

**Example Daily Tip:**
> "Good morning! Delhi AQI is 280 (poor). For your pre-diabetes condition:
> - Eat low GI breakfast (oats with berries, not white bread)
> - Walk indoors today (avoid outdoor pollution)
> - Drink 8 glasses water (pollution + pre-diabetes = dehydration risk)
> 
> ICMR says: Regular low-intensity walking + dietary changes can delay diabetes onset by 5+ years."

---

## 4. TECHNICAL ARCHITECTURE (MVP)

### 4.1 Technology Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Frontend** | Flutter (Android/iOS) | Single codebase, offline-capable |
| **Backend** | Python FastAPI | Fast, async, easy Gemini integration |
| **AI/LLM** | Google Gemini API | Cost-effective, no infrastructure |
| **Database** | PostgreSQL + SQLite | Production-grade + offline sync |
| **Auth** | Firebase/JWT | Quick MVP setup |
| **External APIs** | WAQI, OpenWeather, Google Cloud Vision | Free tier sufficient |
| **Deployment** | AWS/GCP/DigitalOcean | Easy Gemini API integration |
| **Monitoring** | Sentry + CloudWatch | Track errors, API usage |

### 4.2 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER LAYER (Flutter)                    │
│  [Chat Input] [Voice Input] [Report Upload] [History View]      │
└────────────┬────────────────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────────────────┐
│                    GATEWAY LAYER (FastAPI)                      │
│  [Authentication] [Rate Limiting] [Request Validation]          │
│  [Real-time AQI/Weather Fetch] [Image Processing]               │
└────────────┬────────────────────────────────────────────────────┘
             │
         ┌───┴─────────────────────────────────────────┐
         │                                             │
    ┌────▼──────────────┐                  ┌──────────▼─────┐
    │ GEMINI API        │                  │ DATA LAYER     │
    │ (AI Brain)        │                  │ PostgreSQL     │
    │ - Flash 2.0       │                  │ SQLite (Local) │
    │ - 700+ line       │                  │ Redis (Cache)  │
    │   system prompt   │                  │ CloudStorage   │
    │ - 1000 tokens max │                  │ (Reports)      │
    └───┬──────────────┘                  └────────────────┘
        │
    ┌───▴─────────────────────────────────────────┐
    │     CONTEXT INJECTION (Environmental)       │
    │  [AQI] [Weather] [Heatwave] [Pollution]     │
    │  [User Health History] [ICMR Guidelines]    │
    └─────────────────────────────────────────────┘
```

### 4.3 API Endpoints (MVP)

```
Authentication:
  POST /api/v1/auth/register          - User registration
  POST /api/v1/auth/login             - User login
  POST /api/v1/auth/refresh-token     - Refresh JWT

Chat & Health:
  POST /api/v1/chat/message           - Send health query (text)
  POST /api/v1/chat/voice             - Send health query (audio)
  GET /api/v1/chat/history            - Get chat history

Health Tracking:
  POST /api/v1/health/symptom-log     - Log symptoms
  POST /api/v1/health/bp-reading      - Log blood pressure
  POST /api/v1/health/sugar-reading   - Log blood sugar
  GET /api/v1/health/history          - Get health history
  GET /api/v1/health/trends           - Get health trends (charts)

Medical Reports:
  POST /api/v1/reports/upload         - Upload report photo
  GET /api/v1/reports/list            - Get uploaded reports
  GET /api/v1/reports/{id}            - Get report details

Environmental Data:
  GET /api/v1/environment/alerts      - Get AQI/weather alerts
  GET /api/v1/environment/current     - Get current env data

ABDM Integration:
  POST /api/v1/abdm/link              - Link ABHA ID
  GET /api/v1/abdm/records            - Fetch health records
  POST /api/v1/abdm/share             - Share records with provider

Analytics:
  GET /api/v1/analytics/dashboard     - User health dashboard
  GET /api/v1/analytics/report        - Generate health report
```

### 4.4 Gemini API Configuration

**Model Selection for MVP:**
- **Primary:** `gemini-2.0-flash` (latest, fastest, best context window)
- **Fallback:** `gemini-1.5-flash-latest` (more stable if 2.0 has issues)
- **Testing:** `gemini-1.5-flash-lite` (cheapest for testing)

**Rate Limits & Pricing:**
- Free tier: 15 requests/minute, 1.5M tokens/day
- Paid tier: Higher limits ($0.075 per 1M input tokens, $0.30 per 1M output tokens)
- Expected MVP usage: 100K users × 5 queries/day = 500K queries/day = ~₹2000-3000/day at scale

**Request Configuration:**
```python
request = {
    "model": "gemini-2.0-flash",
    "messages": [
        {
            "role": "user",
            "content": f"{SYSTEM_PROMPT}\n\nUser Query: {user_input}"
        }
    ],
    "temperature": 0.3,  # Deterministic for medical
    "top_p": 0.9,
    "max_output_tokens": 1000,
    "timeout_seconds": 10
}
```

---

## 5. SYSTEM PROMPT SPECIFICATION

### 5.1 System Prompt Architecture

**Total Length:** 700-1000 lines (comprehensive guidelines embedded)

**Structure:**
1. **Role Definition** (10 lines): Who you are, what you do
2. **Medical Safety Guidelines** (150 lines): Never diagnose, never prescribe
3. **ICMR Integration** (200 lines): Guidelines for major conditions
4. **Environmental Context** (100 lines): How to use AQI/weather data
5. **Vernacular Handling** (50 lines): Marathi/Hindi nuances
6. **Privacy & Compliance** (50 lines): DPDP Act compliance
7. **Response Format** (30 lines): Structure and tone
8. **Emergency Protocols** (50 lines): When to redirect to 108
9. **Data Handling** (20 lines): User data protection
10. **Edge Cases** (40 lines): How to handle unusual scenarios

### 5.2 System Prompt Template (Excerpt)

**[FULL SYSTEM PROMPT DOCUMENTED IN SEPARATE FILE - See: GEMINI_SYSTEM_PROMPT_700_LINES.md]**

---

## 6. DATA MODELS & SCHEMA

### 6.1 Core Database Tables

```sql
-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR UNIQUE,
  phone VARCHAR UNIQUE,
  name VARCHAR,
  preferred_language VARCHAR(10),  -- 'hi', 'mr', 'en'
  health_id VARCHAR UNIQUE,  -- ABDM ABHA ID
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Health Tracking
CREATE TABLE health_records (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  record_type VARCHAR(50),  -- 'symptom', 'bp', 'sugar', 'weight'
  data JSONB,  -- { symptoms: [...], severity: 1-10, etc }
  recorded_at TIMESTAMP
);

-- Chat History
CREATE TABLE chat_history (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  user_message TEXT,
  ai_response TEXT,
  environmental_context JSONB,  -- { aqi: 350, temp: 42, etc }
  created_at TIMESTAMP
);

-- Medical Reports
CREATE TABLE medical_reports (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  report_date DATE,
  biomarkers JSONB,  -- { glucose: 125, HbA1c: 7.2, etc }
  interpretation TEXT,
  uploaded_at TIMESTAMP
);

-- Environmental Alerts
CREATE TABLE environmental_alerts (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  alert_type VARCHAR(50),  -- 'aqi', 'heatwave', 'monsoon'
  severity VARCHAR(20),  -- 'critical', 'high', 'moderate'
  location VARCHAR,
  created_at TIMESTAMP
);

-- Subscriptions (for B2B)
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  plan VARCHAR(50),  -- 'free', 'premium', 'corporate'
  status VARCHAR(20),  -- 'active', 'paused', 'cancelled'
  billing_cycle VARCHAR(20),  -- 'monthly', 'annual'
  started_at TIMESTAMP,
  ends_at TIMESTAMP
);
```

---

## 7. MONETIZATION (MVP Phase)

### 7.1 Pricing Strategy

**Consumer:**
- **Free Tier:** Limited daily queries (5/day), environmental alerts only
- **Premium:** ₹99/month or ₹999/year → Unlimited queries, report OCR, ad-free

**Corporate/B2B:**
- **Wellness Tier:** ₹10-50 Lakhs/year → Employee health tracking, corporate dashboard
- **Healthcare Tier:** ₹50-200 Lakhs/year → Patient monitoring, provider integration

### 7.2 Revenue Projections (Conservative)

| Metric | Target |
|--------|--------|
| **Year 1 Consumer Users** | 50K-100K |
| **Premium Conversion** | 5-10% = 2.5K-10K |
| **Premium ARPU** | ₹800/year = ₹67/month effective |
| **Year 1 Consumer Revenue** | ₹2-8 Lakhs |
| **Corporate Contracts** | 5-10 signed |
| **Year 1 B2B Revenue** | ₹50-200 Lakhs |
| **Year 1 Total Revenue** | ₹52-208 Lakhs |

**Cost Structure:**
- Gemini API: ~₹2000-5000/day at 100K users
- Infrastructure: ~₹50K-100K/month (FastAPI server, DB)
- Team: ₹5-8 Lakhs/month (founder + 2-3 engineers)
- Burn rate: ~₹10-12 Lakhs/month

**Runway:** 6-12 months with initial ₹50-100 Lakh funding

---

## 8. LAUNCH STRATEGY (MVP)

### Phase 1: Alpha (Week 1-2)
- Internal testing only
- Founder + team use only
- Bug fixes and refinement

### Phase 2: Beta (Week 3-4)
- 100-500 beta testers (organic referral)
- Collect feedback
- Iterate on core features

### Phase 3: Soft Launch (Week 5)
- 5000 users via LinkedIn/Twitter
- Collect testimonials
- Refine pricing

### Phase 4: Public Launch (Week 6-8)
- App store listing (Google Play, iOS)
- Marketing blitz (social media, B2B outreach)
- Target: 50K+ downloads in first month

### Post-MVP Roadmap:
- **Month 2:** Wearable integration, advanced analytics
- **Month 3:** Doctor booking integration, premium consultations
- **Month 4-6:** Government partnerships, enterprise sales

---

## 9. SUCCESS METRICS (MVP)

### User Engagement:
- D30 retention > 40%
- Daily active users (DAU) > 20% of MAU
- Average session: 5-10 minutes
- Queries per user per day: 3-5

### Product Quality:
- AI response satisfaction: 85%+ (via surveys)
- Medical accuracy validation: 90%+
- App crash rate: <0.1%
- API uptime: 99.5%+

### Business Metrics:
- Premium conversion: 5-10%
- CAC: <₹500 (consumer), <₹50K (corporate)
- LTV: >₹5000 (consumer), >₹10 Lakhs (corporate)
- Churn rate: <5% monthly

---

## 10. CONSTRAINTS & ASSUMPTIONS

### Constraints:
- ✅ Gemini API rate limits (15 req/min free tier)
- ✅ No internet = reduced functionality
- ✅ Medical liability requires disclaimers
- ✅ DPDP Act compliance required
- ✅ ICMR copyright restrictions on guidelines

### Assumptions:
- ✅ 10-15% premium conversion (health apps average)
- ✅ 40%+ D30 retention (health apps average)
- ✅ Corporate willing to pay ₹10-50 Lakhs for wellness
- ✅ Users trust AI health guidance with disclaimers
- ✅ Android + iOS simultaneous launch possible

---

## 11. RISKS & MITIGATION

| Risk | Severity | Mitigation |
|------|----------|-----------|
| **Medical liability** | HIGH | Medical Advisory Board, clear disclaimers, no diagnosis claims |
| **Gemini API costs scale** | MEDIUM | Implement caching, rate limiting, cheaper model fallback |
| **User privacy concerns** | HIGH | DPDP compliance audit, end-to-end encryption, transparency |
| **Low premium conversion** | MEDIUM | Focus on B2B revenue, corporate wellness higher margin |
| **Competitor copies** | MEDIUM | Speed to market, build moat via data + partnerships |
| **Regulatory changes** | MEDIUM | Legal team monitoring, early ICMR/MoHFW engagement |

---

## 12. NEXT STEPS

### Immediate (This Week):
1. ✅ Approve PRD (this document)
2. ✅ Review 700-line system prompt (separate file)
3. ✅ Get API keys ready (Gemini, WAQI, OpenWeather)
4. ✅ Set up dev environment (Flutter, FastAPI, PostgreSQL)

### Week 1-2:
5. ✅ Backend skeleton (FastAPI routes)
6. ✅ Gemini API integration
7. ✅ Database schema implementation
8. ✅ Authentication system

### Week 3-4:
9. ✅ Flutter frontend (main chat screen)
10. ✅ Voice input integration
11. ✅ Environmental data integration
12. ✅ Initial testing

### Week 5-6:
13. ✅ Medical report OCR
14. ✅ Health history tracking
15. ✅ Polish UI/UX
16. ✅ Beta launch

---

**PRD Version:** 1.0 FINAL  
**Status:** Ready for Development  
**Next:** System Prompt Design + Implementation Roadmap  

