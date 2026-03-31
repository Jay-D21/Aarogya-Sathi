# Aarogya Sathi — Product Roadmap (Final)

## MVP → Prototype → Final Product → Future Work

---

## Stage 1: MVP

### Objectives
- Working AI health chat (English, text only)
- Manual health tracking (BP, blood sugar, symptoms, weight)
- Google Fit-style fitness tracking (steps, calories, heart points, workouts, sleep)
- Reminders with notifications and adherence tracking
- Real-time AQI/weather display
- Medical safety enforced on all AI responses

### Features

#### 1. Basic Auth
- Register (email/phone + password)
- Login → JWT tokens (access + refresh)
- Logout, token refresh
- Profile screen (name, DOB, city, height, weight — needed for calorie estimation)

#### 2. AI Health Chat
- Text input only, English
- Gemini 2.0 Flash with system prompt (ICMR guidelines, safety rules)
- Safety pipeline: block diagnosis/prescription, enforce disclaimers, detect emergencies → "Call 108"
- Chat history (scrollable, persisted)
- **NOT context-aware of fitness/reminders in MVP** — just answers health questions

#### 3. Health Tracking (Manual Entry)
- **Blood Pressure** — systolic/diastolic, timestamp, shows ICMR comparison (Normal/Elevated/Stage 1/Stage 2)
- **Blood Sugar** — fasting/random/post-meal, timestamp, ICMR comparison
- **Symptoms** — description, severity (1-10), body area, how long
- **Weight** — manual entry, history list
- Offline support via SQLite → sync when online

#### 4. Fitness Tracking (Google Fit Style)

| Feature | How It Works |
|---------|-------------|
| **Steps** | Background pedometer using phone accelerometer sensor (`pedometer` package). Counts 24/7 even when app is closed (Android foreground service / iOS background mode). Daily/weekly/monthly history. |
| **Calories** | **Total Calories = BMR + Activity Calories**, just like Google Fit. **BMR** (resting burn — breathing, digestion, heartbeat) calculated via Mifflin-St Jeor formula using weight, height, age, gender. Ticks up throughout the day even without movement. **Activity Calories** estimated from steps + workout type/duration. User sees total daily burn on home screen. |
| **Heart Points** | Google's system: 1 point per minute of moderate activity (brisk walk, ~100 steps/min), 2 points per minute of vigorous activity (running, cycling). Calculated from step cadence and workout type. Weekly target: 150 points (WHO recommendation). |
| **Move Minutes** | Total minutes of detected movement per day. Derived from accelerometer — any period with consistent step activity counts. |
| **Workouts** | Auto-detect: walking/running auto-detected from step cadence. Manual log: type (yoga, gym, swimming, cycling, sports, etc.), duration, intensity. Calories estimated per workout type. |
| **Sleep** | Manual entry: bedtime + wake time → calculates hours + quality rating (1-5). Shows history. |
| **Water Intake** | Manual log: glasses or ml per day. Daily target based on weight (30ml per kg). |

**Activity Summary (Home Screen):**
- **Daily card**: Steps (with circular progress ring), calories burned, heart points, move minutes, water glasses
- **Charts**: daily/weekly/monthly bar charts for steps, line chart for weight, sleep duration bars
- **Streaks**: consecutive days of hitting step/heart point targets

#### 5. Reminders + Today's Schedule

| Feature | Details |
|---------|---------|
| **Medication Reminders** | Name, dosage, time, repeat (daily / specific days / weekly). Push notification at scheduled time. |
| **Water Reminders** | "Drink water" at custom intervals (every 1hr / 2hr / custom). |
| **Meal Reminders** | Breakfast/Lunch/Dinner/Snack at set times. |
| **Custom Reminders** | "Check BP", "Take a walk", anything. Time + repeat schedule. |
| **Notifications** | Local push notifications via `flutter_local_notifications`. Fires even when app is closed. |
| **Adherence Logging** | Each notification → user taps "Done" / "Skipped" / "Snoozed". Logged with timestamp. History shows adherence percentage per reminder. |
| **Today's Schedule** | Dedicated screen showing all today's reminders in chronological order. Done/pending status for each. Shows next upcoming reminder prominently. |

#### 6. Environmental Alerts
- Home screen card: current AQI + temperature + weather for user's city
- Color-coded AQI indicator (Good/Moderate/Poor/Severe/Hazardous)
- Fetched on-demand from WAQI + OpenWeatherMap, cached 1 hour
- In-app alert banner when AQI > 300

#### MVP Architecture
```
Flutter App
├── Home Screen
│   ├── AQI/Weather Card
│   ├── Activity Summary Card (steps, cal, heart pts)
│   └── Next Reminder Card
├── Chat Screen (AI health chat)
├── Fitness Tab
│   ├── Steps Dashboard + Charts
│   ├── Workout Log (auto-detect + manual)
│   ├── Sleep Log
│   └── Water Tracker
├── Health Tab
│   ├── BP Entry + History
│   ├── Sugar Entry + History
│   ├── Symptoms Log
│   └── Weight Tracker
├── Reminders Tab
│   ├── Today's Schedule
│   ├── All Reminders (CRUD)
│   └── Adherence History
├── Profile/Settings
└── SQLite (offline storage) → Sync → Backend

Backend (FastAPI)
├── /auth/* (JWT auth)
├── /chat/message (Gemini + safety)
├── /health/* (BP, sugar, symptoms, weight CRUD)
├── /fitness/* (steps, workouts, sleep, water CRUD)
├── /reminders/* (CRUD + adherence logs)
├── /environment/current (AQI + weather)
└── PostgreSQL
```

---

## Stage 2: Prototype

### Objectives
- Multilingual UI (Hindi, Marathi, English)
- AI chat becomes context-aware of the **entire app** (fitness, health, reminders, AQI)
- Push notifications for AQI alerts and health thresholds
- Health trend charts with ICMR reference lines
- Polished UX ready for beta testers

### Features Added

| Feature | Details |
|---------|---------|
| **Multilingual UI** | All screens in Hindi/Marathi/English. User picks language in settings. AI responds in user's preferred language. |
| **AI Full Context Awareness** | Chat now knows: last BP/sugar readings, step count today, active conditions, missed reminders, current AQI, workout history. Gives personalized responses like "You walked 8K steps today but your AQI is 280 — consider indoor exercise." |
| **Health Trend Charts** | Line charts for BP/sugar over 7/30/90 days with ICMR reference ranges overlaid. Weight trend chart. Sleep pattern visualization. |
| **Push Notifications (FCM)** | AQI spike alerts, abnormal health reading warnings, daily health tips |
| **Health Conditions** | User marks chronic conditions (diabetes, hypertension, asthma). AI uses these for context. |
| **Dark Mode** | Full dark theme |
| **Data Export** | Export health + fitness data as CSV/PDF for sharing with doctor |
| **User Preferences** | Notification settings, AQI threshold, preferred language, units (metric/imperial) |
| **Daily Summary Notification** | Morning notification: "Good morning! Delhi AQI: 180. You slept 7hrs. 3 reminders today." |

---

## Stage 3: Final Product

### Objectives
- Full multilingual (7+ major Indian languages)
- Medical report OCR with ICMR interpretation
- Subscription model (Free + Premium ₹99/mo)
- Production infrastructure (Redis, monitoring, auto-scaling)
- App store release (Google Play + Apple App Store)

### Features Added

| Feature | Details |
|---------|---------|
| **7+ Languages** | Hindi, Marathi, Tamil, Telugu, Bengali, Kannada, Gujarati — UI + AI chat |
| **Medical Report OCR** | Photograph blood test → Cloud Vision OCR → Gemini extracts biomarkers → ICMR comparison → highlighted abnormals |
| **Subscription** | Free: 5 chats/day, basic tracking. Premium ₹99/mo: unlimited chat, OCR, advanced analytics. Payment via Razorpay. |
| **Redis** | Session management, rate limiting, caching at scale |
| **Admin Dashboard** | User stats, API costs, error rates, engagement metrics |
| **Advanced Analytics** | Moving averages, trend direction, health risk scoring |
| **Security** | RLS, AES-256 encryption, OWASP audit |
| **Feedback System** | In-app ratings and bug reports |

---

## Stage 4: Future Work

| Feature | Details |
|---------|---------|
| **Voice I/O** | Speech-to-text + text-to-speech in Indian languages |
| **Corporate B2B** | Employer wellness accounts, bulk licensing, dashboards |
| **ABDM/ABHA** | Government health ID integration |
| **Bluetooth BP/Glucometer** | Pair with BLE devices for auto-reading |
| **Wearable Sync** | Fitbit, Apple Watch, Google Fit data import |
| **Telemedicine** | In-app doctor video consultation |
| **Custom AI Model** | Fine-tuned on Indian medical data |
| **Family Management** | One account manages multiple family members |
| **Pharmacy Locator** | Find nearby pharmacies + medicine availability |

---

## 📊 Feature Matrix

| Feature | MVP | Proto | Final | Future |
|---------|:---:|:-----:|:-----:|:------:|
| Auth (JWT) | ✅ | ✅ | ✅ | ✅ |
| AI Chat (text, English) | ✅ | ✅ | ✅ | ✅ |
| Health Tracking (BP/sugar/symptoms/weight) | ✅ | ✅ | ✅ | ✅ |
| Steps (background) | ✅ | ✅ | ✅ | ✅ |
| Calories + Heart Points + Move Mins | ✅ | ✅ | ✅ | ✅ |
| Workouts (auto-detect + manual) | ✅ | ✅ | ✅ | ✅ |
| Sleep (manual) | ✅ | ✅ | ✅ | ✅ |
| Water Intake | ✅ | ✅ | ✅ | ✅ |
| Activity Summary Cards + Charts | ✅ | ✅ | ✅ | ✅ |
| Reminders + Notifications | ✅ | ✅ | ✅ | ✅ |
| Adherence Logging | ✅ | ✅ | ✅ | ✅ |
| Today's Schedule | ✅ | ✅ | ✅ | ✅ |
| AQI/Weather Display | ✅ | ✅ | ✅ | ✅ |
| Safety Pipeline | ✅ | ✅ | ✅ | ✅ |
| Offline Support | ✅ | ✅ | ✅ | ✅ |
| Multilingual UI (3 langs) | ❌ | ✅ | ✅ | ✅ |
| AI Context-Aware (full app) | ❌ | ✅ | ✅ | ✅ |
| Health Trend Charts | ❌ | ✅ | ✅ | ✅ |
| Push Notifications (FCM) | ❌ | ✅ | ✅ | ✅ |
| Dark Mode | ❌ | ✅ | ✅ | ✅ |
| Data Export | ❌ | ✅ | ✅ | ✅ |
| 7+ Languages | ❌ | ❌ | ✅ | ✅ |
| OCR Reports | ❌ | ❌ | ✅ | ✅ |
| Subscription + Payments | ❌ | ❌ | ✅ | ✅ |
| Redis + Scale Infra | ❌ | ❌ | ✅ | ✅ |
| Voice I/O | ❌ | ❌ | ❌ | ✅ |
| Corporate B2B | ❌ | ❌ | ❌ | ✅ |
| ABDM/ABHA | ❌ | ❌ | ❌ | ✅ |
| Wearable Sync | ❌ | ❌ | ❌ | ✅ |

---

## Constraints

**CAN do on smartphone (no wearable):**
- ✅ Steps (accelerometer), calories (estimated), heart points (from step cadence), move minutes, workout auto-detect (walking/running)
- ✅ Manual: sleep, water, BP, sugar, symptoms, weight, workouts

**CANNOT do on smartphone:**
- ❌ Actual blood pressure measurement
- ❌ Blood sugar measurement
- ❌ Accurate heart rate (camera-based is unreliable)
- ❌ Auto sleep tracking (needs wearable)
- ❌ SpO2 / blood oxygen
