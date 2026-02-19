# AROGYA SATHI MVP - SYSTEM ARCHITECTURE & API SPECIFICATION
## Complete Technical Design From Scratch

**Version:** 2.0 Fresh Design  
**Date:** January 7, 2026  

---

## 1. SYSTEM ARCHITECTURE DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────┐
│                        USER LAYER (Frontend)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │   Flutter    │  │  Web Browser │  │   Wearables (Future)     │  │
│  │ (Android/iOS)│  │   (React)    │  │ (Apple Watch, Fitbit)    │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────────┬───────────┘  │
└─────────┼──────────────────┼──────────────────────────┼─────────────┘
          │                  │                          │
          └──────────────────┼──────────────────────────┘
                             │
                    ┌────────▼─────────┐
                    │  LOAD BALANCER   │
                    │  (Nginx/HAProxy) │
                    └────────┬─────────┘
                             │
┌────────────────────────────┼────────────────────────────────────────┐
│                   API GATEWAY LAYER (FastAPI)                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Authentication │ Rate Limiting │ Request Validation │ Logging  │
│  └──────────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │           Route Handler (28 Endpoints Total)                │  │
│  │  Auth │ Chat │ Health │ Reports │ Environment │ ABDM │ ...  │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
      ┌─────▼────────┐ ┌────▼──────────┐ ┌──▼──────────┐
      │  Gemini API  │ │ PostgreSQL    │ │   Redis     │
      │ (AI Brain)   │ │ (Primary DB)  │ │   (Cache)   │
      │ Flash 2.0    │ │               │ │             │
      └─────┬────────┘ └────┬──────────┘ └──┬──────────┘
            │               │               │
            └───────────────┼───────────────┘
                            │
            ┌───────────────┴───────────────┐
            │                               │
      ┌─────▼──────┐              ┌────────▼──────┐
      │  External  │              │  File Storage │
      │   APIs     │              │  (S3 / GCS)   │
      │ - WAQI     │              └────────┬──────┘
      │ - Weather  │                       │
      │ - Vision   │                       │
      │ - Speech   │              ┌────────▼────────┐
      │ - TTS      │              │   SQLite Local  │
      └────────────┘              │  (Mobile Sync)  │
                                  └─────────────────┘
```

---

## 2. REQUEST/RESPONSE FLOW

### 2.1 Chat Message Flow

```
User Input (Text/Voice)
    ↓
[Flutter App]
    ├─ Speech-to-Text (if voice input)
    └─ Store message locally (SQLite)
    ↓
[HTTP POST /api/v1/chat/message]
    │
[FastAPI Gateway]
    ├─ Authenticate (JWT verify)
    ├─ Rate limit check (Redis)
    ├─ Validate input
    └─ Log request
    ↓
[Health Service]
    ├─ Fetch user health context (PostgreSQL)
    ├─ Get recent health records
    └─ Extract relevant conditions
    ↓
[Environment Service]
    ├─ Fetch AQI data (WAQI API)
    ├─ Fetch weather data (OpenWeatherMap)
    └─ Check for alerts
    ↓
[Gemini Service]
    ├─ Build context string (environment + health + system prompt)
    ├─ Call Gemini API (gemini-2.0-flash)
    ├─ Inject 740-line system prompt
    └─ Get response
    ↓
[Safety Service]
    ├─ Check for diagnosis claims (BLOCK if found)
    ├─ Check for prescriptions (BLOCK if found)
    ├─ Check for emergency keywords (REDIRECT if found)
    ├─ Verify disclaimer present
    └─ Log safety metrics
    ↓
[Database]
    ├─ Save chat_history record
    ├─ Update api_usage metrics
    └─ Store environmental_context snapshot
    ↓
[Response]
    ├─ Send JSON response to app
    ├─ Include disclaimer
    ├─ Include environmental context
    └─ Include safety metadata
    ↓
[Flutter App]
    ├─ Display message with TTS (if enabled)
    ├─ Sync with local SQLite
    └─ Show AQI alert if relevant
```

### 2.2 Health Tracking Flow

```
User Logs BP/Sugar
    ↓
[Flutter App]
    ├─ Validate input (ranges, units)
    ├─ Store locally (SQLite)
    └─ Mark for cloud sync
    ↓
[HTTP POST /api/v1/health/bp-reading]
    │
[FastAPI]
    ├─ Authenticate
    ├─ Validate
    └─ Log
    ↓
[Health Service]
    ├─ Compare against user targets
    ├─ Check for alert thresholds
    └─ Generate recommendations
    ↓
[Database]
    ├─ Insert health_records entry
    ├─ Trigger health_conditions update
    └─ Log to user_analytics
    ↓
[Alert Service]
    ├─ Check if reading abnormal
    ├─ Trigger notification if needed
    └─ Log to environmental_alerts
    ↓
[Response]
    └─ Sync status + recommendations
    ↓
[Flutter App]
    └─ Update health dashboard
```

---

## 3. COMPLETE API SPECIFICATION (28 Endpoints)

### 3.1 Authentication Endpoints (5 endpoints)

#### 1. User Registration
```
POST /api/v1/auth/register
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "phone": "+919876543210",
  "password": "SecurePassword123!",
  "first_name": "Raj",
  "last_name": "Kumar",
  "date_of_birth": "1990-01-15",
  "preferred_language": "hi",
  "preferred_city": "Delhi"
}

Response (201):
{
  "status": "success",
  "data": {
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "message": "Registration successful. Verification email sent."
  }
}
```

#### 2. User Login
```
POST /api/v1/auth/login
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "device_name": "Xiaomi Redmi Note 11",
  "device_os": "Android 12",
  "app_version": "1.0.0"
}

Response (200):
{
  "status": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "first_name": "Raj",
      "preferred_language": "hi"
    }
  }
}
```

#### 3. Refresh Token
```
POST /api/v1/auth/refresh-token
Content-Type: application/json

Request:
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

Response (200):
{
  "status": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600
  }
}
```

#### 4. Logout
```
POST /api/v1/auth/logout
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "message": "Logged out successfully"
}
```

#### 5. Verify Email/Phone
```
POST /api/v1/auth/verify
Content-Type: application/json

Request:
{
  "verification_type": "email",
  "verification_code": "123456"
}

Response (200):
{
  "status": "success",
  "message": "Email verified successfully"
}
```

---

### 3.2 Chat Endpoints (5 endpoints)

#### 1. Send Chat Message
```
POST /api/v1/chat/message
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "message": "Mujhe sardi ahe aur headache hai",
  "language": "mr",
  "include_environmental_context": true
}

Response (200):
{
  "status": "success",
  "data": {
    "chat_id": "550e8400-e29b-41d4-a716-446655440000",
    "user_message": "Mujhe sardi ahe aur headache hai",
    "ai_response": "Based on ICMR guidelines, your symptoms could indicate viral infection. Current AQI in your area is 280 (poor), which may worsen respiratory symptoms. Recommendations: 1. Stay indoors if possible... ⚠️ Consult a doctor for diagnosis.",
    "timestamp": "2026-01-07T16:30:00Z",
    "response_time_ms": 2340,
    "tokens_used": 450,
    "environmental_context": {
      "city": "Delhi",
      "aqi": 280,
      "temperature": 28,
      "humidity": 45
    }
  }
}
```

#### 2. Send Voice Message
```
POST /api/v1/chat/voice
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

Request:
{
  "audio_file": <binary audio file>,
  "audio_language": "hi",
  "output_language": "hi"
}

Response (200):
{
  "status": "success",
  "data": {
    "transcribed_text": "Mujhe sardi ahe aur headache hai",
    "ai_response": "Based on ICMR guidelines...",
    "audio_response_url": "https://storage.googleapis.com/arogya-sathi/audio/...",
    "timestamp": "2026-01-07T16:30:00Z"
  }
}
```

#### 3. Get Chat History
```
GET /api/v1/chat/history?limit=50&offset=0
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "total": 150,
    "limit": 50,
    "offset": 0,
    "messages": [
      {
        "chat_id": "550e8400-e29b-41d4-a716-446655440000",
        "user_message": "Mujhe sardi ahe",
        "ai_response": "Based on ICMR guidelines...",
        "timestamp": "2026-01-07T16:30:00Z",
        "satisfaction_rating": 4
      }
    ]
  }
}
```

#### 4. Rate Chat Response
```
POST /api/v1/chat/{chat_id}/rate
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "rating": 4,
  "feedback": "Helpful but wanted more specific medication info",
  "is_medically_accurate": true
}

Response (200):
{
  "status": "success",
  "message": "Rating saved successfully"
}
```

#### 5. Search Chat History
```
GET /api/v1/chat/search?query=diabetes&limit=20
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "results": [
      {
        "chat_id": "...",
        "user_message": "I have diabetes symptoms",
        "ai_response": "...",
        "timestamp": "2026-01-07T14:00:00Z"
      }
    ],
    "total_found": 5
  }
}
```

---

### 3.3 Health Tracking Endpoints (5 endpoints)

#### 1. Log Blood Pressure
```
POST /api/v1/health/bp-reading
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "systolic": 140,
  "diastolic": 90,
  "heart_rate": 75,
  "measured_at": "2026-01-07T08:30:00Z",
  "notes": "Measured after breakfast"
}

Response (201):
{
  "status": "success",
  "data": {
    "record_id": "550e8400-e29b-41d4-a716-446655440000",
    "systolic": 140,
    "diastolic": 90,
    "status": "elevated",
    "comparison": {
      "average_systolic": 135,
      "trend": "stable"
    },
    "recommendations": "Your BP is consistently above target (140/90). Consider consulting doctor.",
    "alerts": []
  }
}
```

#### 2. Log Blood Sugar
```
POST /api/v1/health/sugar-reading
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "glucose_value": 125,
  "reading_type": "fasting",
  "measured_at": "2026-01-07T08:00:00Z"
}

Response (201):
{
  "status": "success",
  "data": {
    "record_id": "550e8400-e29b-41d4-a716-446655440000",
    "glucose": 125,
    "reading_type": "fasting",
    "status": "elevated",
    "icmr_reference": {
      "normal_range": "70-100 mg/dL",
      "prediabetic_range": "100-125 mg/dL"
    },
    "recommendations": "You're in prediabetic range. ICMR recommends weight loss, exercise, and dietary changes."
  }
}
```

#### 3. Log Symptoms
```
POST /api/v1/health/symptom-log
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "symptoms": ["cough", "sore_throat", "fever"],
  "severity": 6,
  "duration": "3 days",
  "triggers": ["pollution", "cold_weather"],
  "notes": "Started after air quality worsened"
}

Response (201):
{
  "status": "success",
  "data": {
    "record_id": "550e8400-e29b-41d4-a716-446655440000",
    "symptoms": ["cough", "sore_throat", "fever"],
    "severity": 6,
    "environmental_context": {
      "aqi": 280,
      "temperature": 28,
      "correlation": "High AQI may be contributing factor"
    },
    "icmr_guidance": "These symptoms could indicate viral infection. Current AQI (280) may worsen respiratory symptoms. Recommendations: Stay indoors, use N95 mask if needed, monitor for severe symptoms.",
    "when_to_see_doctor": "Seek medical care if: fever >103°F, breathing difficulty, symptoms persist >10 days"
  }
}
```

#### 4. Get Health Records
```
GET /api/v1/health/records?record_type=vitals&days=30&limit=50
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "records": [
      {
        "record_id": "550e8400-e29b-41d4-a716-446655440000",
        "record_type": "vitals",
        "systolic": 140,
        "diastolic": 90,
        "recorded_at": "2026-01-07T08:30:00Z"
      }
    ],
    "summary": {
      "total_records": 30,
      "avg_systolic": 135,
      "avg_diastolic": 88,
      "trend": "stable"
    }
  }
}
```

#### 5. Get Health Trends
```
GET /api/v1/health/trends?metric=blood_pressure&days=90
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "metric": "blood_pressure",
    "period_days": 90,
    "trend_data": [
      {
        "date": "2026-01-07",
        "systolic": 140,
        "diastolic": 90
      }
    ],
    "statistics": {
      "average_systolic": 135,
      "min_systolic": 120,
      "max_systolic": 155,
      "trend_direction": "stable"
    },
    "chart_url": "https://api.example.com/charts/bp_trend_user_123"
  }
}
```

---

### 3.4 Medical Report Endpoints (3 endpoints)

#### 1. Upload Medical Report
```
POST /api/v1/reports/upload
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

Request:
{
  "report_image": <binary JPG/PNG file>,
  "report_date": "2026-01-07",
  "report_type": "blood_test",
  "lab_name": "Pathology Lab, Delhi"
}

Response (201):
{
  "status": "success",
  "data": {
    "report_id": "550e8400-e29b-41d4-a716-446655440000",
    "processing_status": "processing",
    "extracted_biomarkers": {
      "glucose": {
        "value": 125,
        "unit": "mg/dL",
        "confidence": 0.95
      },
      "HbA1c": {
        "value": 7.2,
        "unit": "%",
        "confidence": 0.92
      }
    },
    "interpretation": "Fasting glucose is elevated. HbA1c suggests prediabetic state. Recommend lifestyle modifications and doctor consultation.",
    "abnormal_values": {
      "glucose": {
        "value": 125,
        "normal_range": "70-100 mg/dL",
        "severity": "mild"
      }
    }
  }
}
```

#### 2. Get Reports
```
GET /api/v1/reports?limit=10&offset=0
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "reports": [
      {
        "report_id": "550e8400-e29b-41d4-a716-446655440000",
        "report_date": "2026-01-07",
        "report_type": "blood_test",
        "biomarkers": {
          "glucose": 125,
          "HbA1c": 7.2
        },
        "uploaded_at": "2026-01-07T10:00:00Z"
      }
    ],
    "total": 5
  }
}
```

#### 3. Get Report Details
```
GET /api/v1/reports/{report_id}
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "report_id": "550e8400-e29b-41d4-a716-446655440000",
    "report_date": "2026-01-07",
    "extracted_text": "[Full OCR extracted text]",
    "biomarkers": {
      "glucose": 125,
      "HbA1c": 7.2,
      "total_cholesterol": 220,
      "HDL": 50,
      "LDL": 150,
      "triglycerides": 200
    },
    "interpretation": "Based on ICMR guidelines...",
    "health_risks": [
      {
        "risk": "diabetes_type2",
        "confidence": 0.85,
        "recommendation": "Weight loss, exercise, dietary modifications"
      }
    ],
    "image_url": "https://storage.googleapis.com/..."
  }
}
```

---

### 3.5 Environmental Data Endpoints (2 endpoints)

#### 1. Get Environmental Alerts
```
GET /api/v1/environment/alerts?limit=10
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "alerts": [
      {
        "alert_id": "550e8400-e29b-41d4-a716-446655440000",
        "alert_type": "aqi_spike",
        "severity": "critical",
        "title": "Severe Air Pollution Alert",
        "description": "AQI has spiked to 380 (Severe). All groups should avoid outdoor activities.",
        "aqi": 380,
        "temperature": 42,
        "recommendations": [
          "Stay indoors",
          "Use N95 mask if outside",
          "Increase air purifier usage",
          "Increase water intake"
        ],
        "created_at": "2026-01-07T14:30:00Z",
        "expires_at": "2026-01-07T18:00:00Z"
      }
    ],
    "current_conditions": {
      "city": "Delhi",
      "aqi": 380,
      "aqi_level": "Severe",
      "temperature": 42,
      "humidity": 25,
      "wind_speed": 2
    }
  }
}
```

#### 2. Get Current Environment Data
```
GET /api/v1/environment/current
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "location": {
      "city": "Delhi",
      "latitude": 28.7041,
      "longitude": 77.1025
    },
    "aqi": {
      "value": 280,
      "level": "Poor",
      "pm25": 195,
      "pm10": 285,
      "no2": 45,
      "so2": 15
    },
    "weather": {
      "temperature": 28,
      "humidity": 45,
      "wind_speed": 8,
      "wind_direction": "NE",
      "condition": "Partly Cloudy"
    },
    "health_recommendations": {
      "respiratory": "Poor air quality. Limit outdoor activities, use N95 mask if outside.",
      "cardiovascular": "AQI level may stress cardiovascular system. Monitor BP.",
      "general": "Stay hydrated, avoid peak sun hours."
    },
    "updated_at": "2026-01-07T16:00:00Z"
  }
}
```

---

### 3.6 ABDM Integration Endpoints (3 endpoints)

#### 1. Link ABHA ID
```
POST /api/v1/abdm/link
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "abha_number": "14-1234-5678-9012",
  "consent_manager_id": "cmid_123"
}

Response (200):
{
  "status": "success",
  "data": {
    "abha_linked": true,
    "abha_number": "14-1234-5678-9012",
    "linked_at": "2026-01-07T16:30:00Z",
    "next_step": "Grant consent to health facilities"
  }
}
```

#### 2. Share Health Records via ABDM
```
POST /api/v1/abdm/share-records
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "health_facility_id": "facility_123",
  "records_to_share": ["recent_labs", "vitals", "chat_history"],
  "consent_expiry": "2026-01-31"
}

Response (200):
{
  "status": "success",
  "data": {
    "share_id": "share_550e8400-e29b-41d4-a716-446655440000",
    "shared_with": "facility_123",
    "records_count": 3,
    "shared_at": "2026-01-07T16:30:00Z",
    "expires_at": "2026-01-31T23:59:59Z"
  }
}
```

#### 3. Get Shared Records Status
```
GET /api/v1/abdm/share-status
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "active_shares": [
      {
        "share_id": "share_550e8400-e29b-41d4-a716-446655440000",
        "shared_with": "Apollo Hospital",
        "records_count": 15,
        "shared_at": "2026-01-05T10:00:00Z",
        "expires_at": "2026-01-31T23:59:59Z",
        "access_log": [
          {
            "accessed_at": "2026-01-06T14:00:00Z",
            "accessed_by": "Dr. Sharma"
          }
        ]
      }
    ]
  }
}
```

---

### 3.7 Analytics Endpoints (2 endpoints)

#### 1. Get Health Dashboard
```
GET /api/v1/analytics/dashboard
Authorization: Bearer {access_token}

Response (200):
{
  "status": "success",
  "data": {
    "user_profile": {
      "name": "Raj Kumar",
      "age": 35,
      "bmi": 26.5,
      "health_score": 72
    },
    "vital_statistics": {
      "avg_bp": "135/88",
      "avg_glucose": "125 mg/dL",
      "weight_trend": "stable"
    },
    "active_conditions": [
      {
        "condition": "Prediabetes",
        "severity": "moderate",
        "management": "Lifestyle modifications"
      }
    ],
    "recent_activity": {
      "messages_this_week": 15,
      "health_logs_this_week": 8,
      "last_activity": "2026-01-07T16:00:00Z"
    },
    "environmental_exposure": {
      "avg_aqi_30days": 280,
      "high_pollution_days": 15,
      "recommendations": "Increase antioxidant intake"
    }
  }
}
```

#### 2. Generate Health Report
```
POST /api/v1/analytics/generate-report
Authorization: Bearer {access_token}
Content-Type: application/json

Request:
{
  "report_type": "monthly",
  "start_date": "2025-12-01",
  "end_date": "2026-01-07",
  "include_sections": ["vitals", "conditions", "recommendations", "environmental"]
}

Response (200):
{
  "status": "success",
  "data": {
    "report_id": "report_550e8400-e29b-41d4-a716-446655440000",
    "report_type": "monthly",
    "period": "2025-12-01 to 2026-01-07",
    "download_url": "https://storage.googleapis.com/reports/report_123.pdf",
    "generated_at": "2026-01-07T16:30:00Z"
  }
}
```

---

## 4. ERROR RESPONSES (Standard Format)

```json
{
  "status": "error",
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "systolic",
        "error": "must be between 50 and 300"
      }
    ]
  },
  "timestamp": "2026-01-07T16:30:00Z"
}
```

### 4.1 HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | OK | Successful request |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Validation error |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | User not allowed |
| 404 | Not Found | Resource doesn't exist |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Server Error | Unexpected error |

---

## 5. AUTHENTICATION & SECURITY

### 5.1 JWT Token Structure

```
Header:
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload:
{
  "sub": "user_550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "phone": "+919876543210",
  "preferred_language": "hi",
  "subscription_plan": "premium",
  "iat": 1704621000,
  "exp": 1704624600,
  "iss": "arogya-sathi-mvp"
}
```

### 5.2 API Key Authentication (B2B)

```
For Corporate/ABDM integration:
Authorization: APIKey {corporate_api_key}

Corporate API Key Format:
- Length: 32 characters
- Prefix: "asahi_"
- Example: asahi_9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d
```

---

## 6. RATE LIMITING

```
Free Tier:
- 15 requests/minute
- 500 requests/day
- 5 queries simultaneous

Premium Tier:
- 100 requests/minute
- 50,000 requests/day
- 20 queries simultaneous

Corporate Tier:
- Custom limits
- Dedicated support
```

---

## 7. CACHING STRATEGY

```
Cache TTL:
- User profile: 24 hours
- Health records: 12 hours
- Environmental data (AQI): 1 hour
- Chat responses: 30 minutes (for identical queries)
- API responses: 5 minutes (default)

Cache Keys:
- health:{user_id}:vitals
- environment:{city}:aqi
- chat:{user_id}:{message_hash}
```

---

## 8. API VERSIONING

```
Current Version: v1
URL Format: /api/v1/...

Future Versions:
- v2: Expected in Month 6 (major feature additions)
- Backward compatibility: All v1 endpoints supported in v2

Deprecation Policy:
- v1 supported for minimum 12 months
- 6 months notice before deprecation
- Automatic redirection from deprecated versions
```

---

**API SPECIFICATION COMPLETE & READY FOR IMPLEMENTATION**

**Status:** ✅ Production-Ready  
**Total Endpoints:** 28  
**Authentication:** JWT + API Key  
**Response Format:** JSON  
**Rate Limiting:** Implemented  
**Versioning:** v1 (future-proof)  

