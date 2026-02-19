# AROGYA SATHI MVP - IMPLEMENTATION GUIDE FOR AI DEVELOPERS
## Complete Specifications for Claude, ChatGPT, or Any AI IDE

**Version:** 1.0 MVP  
**Status:** Ready for Development  
**Timeline:** 4-6 weeks  
**Target:** Commercial Launch  

---

## TABLE OF CONTENTS

1. [Quick Start](#quick-start)
2. [Project Structure](#project-structure)
3. [Development Phases](#development-phases)
4. [API Keys & Setup](#api-keys--setup)
5. [Backend Implementation (FastAPI)](#backend-implementation-fastapi)
6. [Frontend Implementation (Flutter)](#frontend-implementation-flutter)
7. [Gemini API Integration](#gemini-api-integration)
8. [Database Schema](#database-schema)
9. [Testing & QA](#testing--qa)
10. [Deployment](#deployment)

---

## QUICK START

### For Claude/ChatGPT Users:

1. **Copy PRD:** [AROGYA_SATHI_MVP_PRD_GEMINI_API.md](./AROGYA_SATHI_MVP_PRD_GEMINI_API.md)
2. **Copy System Prompt:** [GEMINI_SYSTEM_PROMPT_740_LINES.md](./GEMINI_SYSTEM_PROMPT_740_LINES.md)
3. **Request:** "Based on the PRD and system prompt, generate Python FastAPI backend code for..."
4. **Iterate:** Ask for specific modules, features, or components one at a time

### Key Commands to Use:

```
"Generate [component] code based on the PRD"
"Create unit tests for [function]"
"Debug this error: [error message]"
"Optimize this code for [metric]"
"Generate Docker configuration"
```

---

## PROJECT STRUCTURE

```
arogya-sathi-mvp/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                 # FastAPI app
│   │   ├── config.py               # Config management
│   │   ├── dependencies.py         # Dependency injection
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   ├── auth.py             # Authentication endpoints
│   │   │   ├── chat.py             # Chat & health queries
│   │   │   ├── health.py           # Health tracking
│   │   │   ├── reports.py          # Medical report OCR
│   │   │   ├── environment.py      # AQI & weather
│   │   │   ├── abdm.py             # ABDM integration
│   │   │   └── analytics.py        # Dashboard & analytics
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   ├── user.py             # User SQLAlchemy model
│   │   │   ├── health.py           # Health record models
│   │   │   ├── chat.py             # Chat history model
│   │   │   └── report.py           # Medical report model
│   │   ├── schemas/
│   │   │   ├── __init__.py
│   │   │   ├── user.py             # Request/response Pydantic models
│   │   │   ├── health.py
│   │   │   ├── chat.py
│   │   │   └── report.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   ├── gemini_service.py   # Gemini API wrapper
│   │   │   ├── auth_service.py     # JWT & OAuth
│   │   │   ├── health_service.py   # Health logic
│   │   │   ├── ocr_service.py      # Report processing
│   │   │   ├── environment_service.py # AQI/Weather fetching
│   │   │   └── cache_service.py    # Redis caching
│   │   ├── utils/
│   │   │   ├── __init__.py
│   │   │   ├── logger.py           # Logging
│   │   │   ├── validators.py       # Data validation
│   │   │   ├── exceptions.py       # Custom exceptions
│   │   │   └── constants.py        # App constants
│   │   └── db/
│   │       ├── __init__.py
│   │       ├── database.py         # DB connection
│   │       ├── base.py             # Base models
│   │       └── session.py          # Session management
│   ├── tests/
│   │   ├── __init__.py
│   │   ├── test_auth.py
│   │   ├── test_chat.py
│   │   ├── test_health.py
│   │   ├── test_gemini_service.py
│   │   └── conftest.py             # Pytest fixtures
│   ├── migrations/                 # Alembic DB migrations
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── .env.example
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart               # App entry point
│   │   ├── config/
│   │   │   ├── api_config.dart
│   │   │   └── theme.dart
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── chat/
│   │   │   │   ├── chat_screen.dart
│   │   │   │   └── voice_input_widget.dart
│   │   │   ├── health/
│   │   │   │   ├── health_history_screen.dart
│   │   │   │   ├── add_bp_screen.dart
│   │   │   │   └── add_sugar_screen.dart
│   │   │   ├── reports/
│   │   │   │   ├── report_upload_screen.dart
│   │   │   │   └── report_view_screen.dart
│   │   │   ├── environment/
│   │   │   │   └── aqi_alerts_screen.dart
│   │   │   └── analytics/
│   │   │       └── dashboard_screen.dart
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── health_model.dart
│   │   │   ├── chat_model.dart
│   │   │   └── report_model.dart
│   │   ├── services/
│   │   │   ├── api_service.dart    # HTTP client wrapper
│   │   │   ├── auth_service.dart
│   │   │   ├── health_service.dart
│   │   │   ├── storage_service.dart # Local storage (SQLite)
│   │   │   └── notification_service.dart
│   │   ├── providers/              # State management (Riverpod/Provider)
│   │   │   ├── auth_provider.dart
│   │   │   ├── health_provider.dart
│   │   │   └── chat_provider.dart
│   │   ├── widgets/
│   │   │   ├── chat_bubble.dart
│   │   │   ├── health_card.dart
│   │   │   ├── aqi_indicator.dart
│   │   │   └── common_widgets.dart
│   │   └── utils/
│   │       ├── constants.dart
│   │       ├── validators.dart
│   │       └── formatters.dart
│   ├── assets/
│   │   ├── images/
│   │   ├── icons/
│   │   └── translations/
│   ├── pubspec.yaml
│   ├── Dockerfile
│   └── README.md
│
├── docs/
│   ├── API_DOCUMENTATION.md
│   ├── DEPLOYMENT_GUIDE.md
│   ├── TESTING_STRATEGY.md
│   └── TROUBLESHOOTING.md
│
├── .github/
│   └── workflows/
│       ├── backend_tests.yml       # CI/CD pipeline
│       └── frontend_build.yml
│
├── docker-compose.yml              # Full stack
├── README.md
└── DEPLOYMENT_CHECKLIST.md

```

---

## DEVELOPMENT PHASES

### Phase 1: Backend Skeleton (Week 1)
**Goal:** API ready to receive requests

**Tasks:**
1. ✅ FastAPI project setup
2. ✅ PostgreSQL + SQLAlchemy models
3. ✅ Gemini API client wrapper
4. ✅ Authentication (JWT)
5. ✅ Basic chat endpoint (connects to Gemini)
6. ✅ Error handling & logging

**Deliverable:** `POST /api/v1/chat/message` returns Gemini response

---

### Phase 2: Health Tracking (Week 2)
**Goal:** Users can track health metrics

**Tasks:**
1. ✅ Health record CRUD endpoints
2. ✅ Database schema for BP, sugar, symptoms
3. ✅ Health history retrieval
4. ✅ Data validation

**Deliverable:** Users can log BP/sugar/symptoms and retrieve history

---

### Phase 3: Frontend Basics (Week 2-3)
**Goal:** Mobile app shell working

**Tasks:**
1. ✅ Flutter project setup (Android + iOS)
2. ✅ Authentication screens (login/register)
3. ✅ Home screen layout
4. ✅ Chat screen (text input only)
5. ✅ Basic API integration
6. ✅ Local storage (SQLite)

**Deliverable:** App can login, show home screen, send text chat

---

### Phase 4: Environmental Integration (Week 3)
**Goal:** AQI & weather context working

**Tasks:**
1. ✅ WAQI API integration (backend)
2. ✅ OpenWeatherMap integration
3. ✅ Environmental context injection to Gemini
4. ✅ AQI alerts endpoint
5. ✅ Frontend: AQI display screen

**Deliverable:** App shows current AQI; chat considers environment

---

### Phase 5: Voice & Medical Reports (Week 4)
**Goal:** Voice input and OCR working

**Tasks:**
1. ✅ Whisper API integration (Google Cloud)
2. ✅ TTS integration (Google Cloud)
3. ✅ Report upload endpoint
4. ✅ OCR via Cloud Vision API
5. ✅ Biomarker extraction logic
6. ✅ Frontend: Voice input widget
7. ✅ Frontend: Report upload screen

**Deliverable:** Users can speak, app responds with audio; upload reports

---

### Phase 6: Polish & Testing (Week 5)
**Goal:** MVP ready for beta

**Tasks:**
1. ✅ UI/UX refinements
2. ✅ Performance optimization
3. ✅ Security audit
4. ✅ Load testing (Gemini API rate limits)
5. ✅ Bug fixes
6. ✅ Medical accuracy review

**Deliverable:** Polished, tested, secure MVP

---

### Phase 7: Beta Launch (Week 6)
**Goal:** Real users testing

**Tasks:**
1. ✅ App store submission (beta)
2. ✅ Marketing materials
3. ✅ Beta tester onboarding
4. ✅ Feedback collection
5. ✅ Iteration based on feedback

**Deliverable:** Beta app on TestFlight/Google Play

---

## API KEYS & SETUP

### Required API Keys

| Service | Key | Free Tier Limit | Cost at Scale |
|---------|-----|-----------------|----------------|
| **Gemini API** | Google Cloud | 15 req/min, 1.5M tokens/day | $0.075/1M input, $0.30/1M output tokens |
| **WAQI (AQI)** | waqi.info | 10,000 calls/day | Free or ₹500/mo |
| **OpenWeatherMap** | openweathermap.org | 1,000 calls/day | $5.99/mo |
| **Google Cloud Vision** | gcloud | 1000 reqs/mo free | $1.50 per 1000 reqs after |
| **Firebase Auth** | Google | Unlimited auth | Included |
| **PostgreSQL** | Any cloud provider | AWS RDS free tier | $30-100/mo |

### Setup Instructions

**Step 1: Google Cloud Project**
```bash
# Create project
gcloud projects create arogya-sathi-mvp

# Enable APIs
gcloud services enable genai.googleapis.com
gcloud services enable vision.googleapis.com
gcloud services enable texttospeech.googleapis.com
gcloud services enable speechtotext.googleapis.com

# Create service account
gcloud iam service-accounts create arogya-sathi-service
gcloud iam service-accounts keys create key.json \
  --iam-account=arogya-sathi-service@arogya-sathi-mvp.iam.gserviceaccount.com

# Export credentials
export GOOGLE_APPLICATION_CREDENTIALS=./key.json
```

**Step 2: Environment Variables**
```bash
# .env file
GOOGLE_API_KEY=your-gemini-api-key
WAQI_API_KEY=your-waqi-key
OPENWEATHER_API_KEY=your-weather-key
DATABASE_URL=postgresql://user:pass@localhost/arogya_db
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key-here
JWT_ALGORITHM=HS256
```

**Step 3: Database Setup**
```bash
# Create PostgreSQL database
createdb arogya_sathi_mvp

# Run migrations
cd backend && alembic upgrade head
```

**Step 4: Install Dependencies**
```bash
# Backend
cd backend && pip install -r requirements.txt

# Frontend
cd frontend && flutter pub get
```

---

## BACKEND IMPLEMENTATION (FastAPI)

### Step 1: Create requirements.txt

```
fastapi==0.104.1
uvicorn==0.24.0
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9
pydantic==2.5.0
pydantic-settings==2.1.0
google-cloud-vision==3.4.4
google-cloud-texttospeech==2.14.1
google-cloud-speech==2.21.1
google-generativeai==0.3.0
aioredis==2.0.1
python-jose==3.3.0
passlib==1.7.4
python-multipart==0.0.6
pytest==7.4.3
pytest-asyncio==0.21.1
httpx==0.25.2
python-dotenv==1.0.0
requests==2.31.0
pillow==10.1.0
opencv-python==4.8.1.78
pytesseract==0.3.10
```

### Step 2: Main FastAPI App (main.py)

```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging

from app.config import settings
from app.routes import auth, chat, health, reports, environment, abdm, analytics
from app.db.database import engine, Base
from app.utils.logger import get_logger

logger = get_logger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting Arogya Sathi MVP Server")
    Base.metadata.create_all(bind=engine)
    yield
    # Shutdown
    logger.info("Shutting down Arogya Sathi MVP Server")

app = FastAPI(
    title="Arogya Sathi MVP API",
    description="Environment-aware health assistant for urban India",
    version="1.0.0",
    lifespan=lifespan
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["Chat"])
app.include_router(health.router, prefix="/api/v1/health", tags=["Health Tracking"])
app.include_router(reports.router, prefix="/api/v1/reports", tags=["Medical Reports"])
app.include_router(environment.router, prefix="/api/v1/environment", tags=["Environment"])
app.include_router(abdm.router, prefix="/api/v1/abdm", tags=["ABDM"])
app.include_router(analytics.router, prefix="/api/v1/analytics", tags=["Analytics"])

@app.get("/")
async def root():
    return {
        "message": "Arogya Sathi MVP API",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Step 3: Gemini Service (services/gemini_service.py)

```python
import google.generativeai as genai
from typing import Optional
import logging
from app.config import settings
from app.utils.constants import SYSTEM_PROMPT

logger = logging.getLogger(__name__)

class GeminiService:
    def __init__(self):
        genai.configure(api_key=settings.GOOGLE_API_KEY)
        self.model = genai.GenerativeModel(
            model_name="gemini-2.0-flash",
            system_instruction=SYSTEM_PROMPT
        )
        self.chat = None
    
    def start_conversation(self):
        """Start new chat session"""
        self.chat = self.model.start_chat(history=[])
    
    async def get_health_response(
        self,
        user_query: str,
        user_health_history: Optional[dict] = None,
        environmental_context: Optional[dict] = None
    ) -> str:
        """
        Get health response from Gemini with context
        """
        # Build context
        context = self._build_context(user_health_history, environmental_context)
        
        # Combine context + query
        full_query = f"{context}\n\nUser Query: {user_query}"
        
        try:
            response = self.chat.send_message(
                full_query,
                generation_config=genai.types.GenerationConfig(
                    temperature=0.3,  # Lower for medical accuracy
                    top_p=0.9,
                    max_output_tokens=1000
                )
            )
            
            return response.text
        
        except Exception as e:
            logger.error(f"Gemini API error: {str(e)}")
            raise
    
    def _build_context(self, health_history: Optional[dict], env_data: Optional[dict]) -> str:
        """Build context from health and environmental data"""
        context_parts = []
        
        if health_history:
            context_parts.append(f"User Health Context: {health_history}")
        
        if env_data:
            context_parts.append(
                f"Environmental Data:\n"
                f"- Location: {env_data.get('city')}\n"
                f"- AQI: {env_data.get('aqi')} ({env_data.get('aqi_level')})\n"
                f"- Temperature: {env_data.get('temperature')}°C\n"
                f"- Humidity: {env_data.get('humidity')}%"
            )
        
        return "\n".join(context_parts) if context_parts else "No contextual data available."

gemini_service = GeminiService()
```

### Step 4: Chat Endpoint (routes/chat.py)

```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.db.database import get_db
from app.services.gemini_service import gemini_service
from app.services.environment_service import get_environmental_context
from app.models import ChatHistory
from app.utils.logger import get_logger

logger = get_logger(__name__)
router = APIRouter()

class ChatRequest(BaseModel):
    message: str
    user_id: str

class ChatResponse(BaseModel):
    user_message: str
    ai_response: str
    timestamp: str

@router.post("/message")
async def send_message(
    request: ChatRequest,
    db: Session = Depends(get_db)
) -> ChatResponse:
    """Send health query to AI"""
    try:
        # Get environmental context
        env_context = await get_environmental_context(user_id=request.user_id)
        
        # Get response from Gemini
        response = await gemini_service.get_health_response(
            user_query=request.message,
            environmental_context=env_context
        )
        
        # Save to database
        chat_record = ChatHistory(
            user_id=request.user_id,
            user_message=request.message,
            ai_response=response,
            environmental_context=env_context
        )
        db.add(chat_record)
        db.commit()
        
        return ChatResponse(
            user_message=request.message,
            ai_response=response,
            timestamp=chat_record.created_at.isoformat()
        )
    
    except Exception as e:
        logger.error(f"Chat endpoint error: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to process message")

@router.get("/history/{user_id}")
async def get_chat_history(user_id: str, db: Session = Depends(get_db)):
    """Get user's chat history"""
    history = db.query(ChatHistory).filter(
        ChatHistory.user_id == user_id
    ).order_by(ChatHistory.created_at.desc()).limit(50).all()
    
    return [
        {
            "user_message": h.user_message,
            "ai_response": h.ai_response,
            "timestamp": h.created_at.isoformat()
        }
        for h in history
    ]
```

### Step 5: Environment Service

```python
import httpx
from app.config import settings

class EnvironmentService:
    async def get_aqi_data(self, city: str) -> dict:
        """Fetch AQI from WAQI API"""
        url = f"https://api.waqi.info/feed/{city}/?token={settings.WAQI_API_KEY}"
        
        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            data = response.json()
            
            if data['status'] == 'ok':
                aqi = data['data']['aqi']
                return {
                    'aqi': aqi,
                    'aqi_level': self._aqi_level(aqi)
                }
            return None
    
    async def get_weather_data(self, lat: float, lon: float) -> dict:
        """Fetch weather from OpenWeatherMap"""
        url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={settings.OPENWEATHER_API_KEY}&units=metric"
        
        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            data = response.json()
            
            return {
                'temperature': data['main']['temp'],
                'humidity': data['main']['humidity'],
                'description': data['weather'][0]['description']
            }
    
    def _aqi_level(self, aqi: int) -> str:
        if aqi <= 50:
            return "Good"
        elif aqi <= 100:
            return "Satisfactory"
        elif aqi <= 200:
            return "Moderately Polluted"
        elif aqi <= 300:
            return "Poor"
        elif aqi <= 400:
            return "Severe"
        else:
            return "Hazardous"

environment_service = EnvironmentService()
```

---

## FRONTEND IMPLEMENTATION (Flutter)

### Step 1: pubspec.yaml

```yaml
name: arogya_sathi
description: Environment-aware health assistant for urban India

version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  
  # HTTP
  http: ^1.1.0
  dio: ^5.3.0
  
  # Local storage
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # Authentication
  firebase_core: ^24.0.0
  firebase_auth: ^4.10.0
  
  # UI
  flutter_svg: ^2.0.0
  google_fonts: ^6.1.0
  lottie: ^2.7.0
  
  # Voice & Audio
  speech_to_text: ^6.4.0
  flutter_tts: ^0.13.8
  
  # Camera for report upload
  image_picker: ^1.0.4
  
  # Charts
  fl_chart: ^0.66.0
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.0.0
  logger: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.6
```

### Step 2: Main App (main.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ArogyaSathiApp(),
    ),
  );
}

class ArogyaSathiApp extends ConsumerWidget {
  const ArogyaSathiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Arogya Sathi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### Step 3: Chat Screen (screens/chat/chat_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/chat_model.dart';
import '../../services/api_service.dart';
import '../../widgets/chat_bubble.dart';
import 'voice_input_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String userId;
  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  List<ChatMessage> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _initializeTts();
    _loadChatHistory();
  }

  void _initializeTts() async {
    await _tts.setLanguage('hi'); // Default to Hindi
    await _tts.setSpeechRate(0.5);
  }

  void _loadChatHistory() async {
    final apiService = ApiService();
    try {
      final history = await apiService.getChatHistory(widget.userId);
      setState(() {
        messages = history;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load history: $e')),
      );
    }
  }

  void _sendMessage(String message) async {
    final apiService = ApiService();
    
    setState(() {
      messages.add(ChatMessage(
        id: DateTime.now().toString(),
        userMessage: message,
        aiResponse: '',
        timestamp: DateTime.now(),
        isUser: true,
      ));
      isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await apiService.sendMessage(
        userId: widget.userId,
        message: message,
      );

      setState(() {
        messages.add(ChatMessage(
          id: DateTime.now().toString(),
          userMessage: message,
          aiResponse: response,
          timestamp: DateTime.now(),
          isUser: false,
        ));
        isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arogya Sathi'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final msg = messages[index];
                return ChatBubble(message: msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    placeholder Text: 'Ask about your health...',
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _sendMessage(value);
                      }
                    },
                  ),
                ),
                VoiceInputWidget(
                  onVoiceInput: _sendMessage,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }
}
```

---

## GEMINI API INTEGRATION

### Complete Implementation Pattern

```python
async def process_with_gemini(
    user_input: str,
    environmental_context: dict,
    user_health_history: dict
) -> str:
    """
    Complete Gemini integration pattern
    """
    # 1. Build comprehensive context
    context_prompt = f"""
    ENVIRONMENTAL DATA:
    - Location: {environmental_context.get('city')}
    - AQI: {environmental_context.get('aqi')} ({environmental_context.get('aqi_level')})
    - Temperature: {environmental_context.get('temperature')}°C
    - Health Alerts: {environmental_context.get('alerts', [])}
    
    USER HEALTH CONTEXT:
    - Recent BP: {user_health_history.get('recent_bp')}
    - Blood Sugar: {user_health_history.get('recent_sugar')}
    - Active Conditions: {user_health_history.get('conditions', [])}
    - Medications: {user_health_history.get('medications', [])}
    """
    
    # 2. Prepare request
    request_body = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": f"{context_prompt}\n\nUser Query: {user_input}"
                    }
                ]
            }
        ],
        "generation_config": {
            "temperature": 0.3,
            "topP": 0.9,
            "maxOutputTokens": 1000
        }
    }
    
    # 3. Call Gemini API
    response = await gemini_client.generate_content_async(request_body)
    
    # 4. Validate response
    if not response or not response.text:
        raise ValueError("Empty response from Gemini")
    
    # 5. Check for safety violations
    if _has_dangerous_content(response.text):
        return "I cannot provide this information. Please consult a doctor."
    
    # 6. Add disclaimer
    final_response = f"{response.text}\n\n⚠️ Consult a doctor for diagnosis and treatment."
    
    return final_response

def _has_dangerous_content(text: str) -> bool:
    """Check for dangerous patterns"""
    dangerous_patterns = [
        r"you have (diabetes|cancer|heart disease)",
        r"take (metformin|aspirin|amlodipine).*\d+\s*mg",
        r"prescription.*medication",
    ]
    
    for pattern in dangerous_patterns:
        if re.search(pattern, text, re.IGNORECASE):
            return True
    
    return False
```

---

## DATABASE SCHEMA

### SQLAlchemy Models

```python
from sqlalchemy import Column, String, Integer, Float, DateTime, JSON, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
import uuid

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(String, primary_key=True, default=str(uuid.uuid4()))
    email = Column(String, unique=True, index=True)
    phone = Column(String, unique=True)
    name = Column(String)
    hashed_password = Column(String)
    preferred_language = Column(String, default="en")
    health_id = Column(String, unique=True, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class HealthRecord(Base):
    __tablename__ = "health_records"
    
    id = Column(String, primary_key=True, default=str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"))
    record_type = Column(String)  # 'symptom', 'bp', 'sugar', 'weight'
    data = Column(JSON)  # Flexible data storage
    recorded_at = Column(DateTime, default=datetime.utcnow)

class ChatHistory(Base):
    __tablename__ = "chat_history"
    
    id = Column(String, primary_key=True, default=str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"))
    user_message = Column(String)
    ai_response = Column(String)
    environmental_context = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)

class MedicalReport(Base):
    __tablename__ = "medical_reports"
    
    id = Column(String, primary_key=True, default=str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id"))
    report_date = Column(String)
    biomarkers = Column(JSON)  # Extracted values
    interpretation = Column(String)
    uploaded_at = Column(DateTime, default=datetime.utcnow)
```

---

## TESTING & QA

### Test Cases for Chat API

```python
# tests/test_chat.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

@pytest.fixture
def auth_headers():
    """Get authenticated headers"""
    response = client.post("/api/v1/auth/login", json={
        "email": "test@example.com",
        "password": "test123"
    })
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}

def test_send_chat_message(auth_headers):
    """Test sending health query"""
    response = client.post(
        "/api/v1/chat/message",
        json={"message": "I have a cough"},
        headers=auth_headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "ai_response" in data
    assert "cough" in data["ai_response"].lower()
    assert "⚠️" in data["ai_response"]  # Check for disclaimer

def test_no_diagnosis_response(auth_headers):
    """Ensure model doesn't diagnose"""
    response = client.post(
        "/api/v1/chat/message",
        json={"message": "I have cough, fever, and runny nose"},
        headers=auth_headers
    )
    
    data = response.json()
    response_text = data["ai_response"].lower()
    
    # Should NOT contain diagnosis
    assert "you have" not in response_text or "consult" in response_text

def test_aqi_context_response(auth_headers):
    """Test AQI context injection"""
    response = client.post(
        "/api/v1/chat/message",
        json={
            "message": "I have a cough",
            "location": "Delhi"
        },
        headers=auth_headers
    )
    
    data = response.json()
    # Should mention AQI/pollution if in context
    assert "aqi" in data["ai_response"].lower() or "pollution" in data["ai_response"].lower()
```

---

## DEPLOYMENT

### Docker Setup

```dockerfile
# Backend Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: arogya_sathi_mvp
      POSTGRES_USER: arogya
      POSTGRES_PASSWORD: secure_password
    ports:
      - "5432:5432"
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
  
  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://arogya:secure_password@postgres:5432/arogya_sathi_mvp
      REDIS_URL: redis://redis:6379
      GOOGLE_API_KEY: ${GOOGLE_API_KEY}
      WAQI_API_KEY: ${WAQI_API_KEY}
      OPENWEATHER_API_KEY: ${OPENWEATHER_API_KEY}
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis
```

### Deployment Checklist

```
Before launching:
☑ All API keys in secrets manager (not .env)
☑ Database migrations run
☑ Rate limiting configured for Gemini API
☑ CORS origins configured
☑ SSL/TLS certificates installed
☑ Logging & monitoring set up (Sentry)
☑ Medical disclaimer in all responses
☑ 50+ test cases passed
☑ Load testing passed (500 concurrent users)
☑ Security audit completed
☑ Privacy policy updated (DPDP compliance)
☑ Terms & conditions reviewed
☑ Medical Advisory Board approval
☑ Insurance & liability reviewed
```

---

## ASKING AN AI IDE TO BUILD THIS

### Recommended Prompt Strategy

**Prompt 1:**
```
"Based on this PRD for Arogya Sathi MVP (health assistant with Gemini API), 
generate the complete FastAPI backend structure including:
1. Requirements.txt with all dependencies
2. Main app setup (main.py) with all routes
3. Gemini service wrapper
4. Chat endpoint implementation
5. Database models and schema

Use Python 3.11, async/await, and PostgreSQL."
```

**Prompt 2:**
```
"Now create the Flutter frontend for the chat screen including:
1. pubspec.yaml with dependencies
2. Chat screen UI with message bubbles
3. Voice input widget using speech_to_text
4. API integration with the backend
5. Local SQLite storage for offline capability

Use Riverpod for state management and Dart 3.0+"
```

**Prompt 3:**
```
"Generate the Gemini API integration with:
1. System prompt embedding (use this 740-line prompt: [paste prompt])
2. Context injection from environmental + health data
3. Safety checks for diagnosis/prescription patterns
4. Rate limiting for free tier
5. Error handling and fallbacks"
```

---

**Documentation Status:** COMPLETE  
**Ready for AI IDE Development:** YES  
**Next Step:** Copy PRD, System Prompt, and this guide into your AI IDE and start building!  

