from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine
from app.routers import auth, chat, health, fitness, reminders, environment


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🏥 Aarogya Sathi API starting...")
    yield
    await engine.dispose()
    print("🏥 Aarogya Sathi API shutting down...")


app = FastAPI(
    title="Aarogya Sathi API",
    description="AI-Powered Health Companion for Urban India",
    version="1.0.0-mvp",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "aarogya-sathi-api", "version": "1.0.0-mvp"}


# ── Routers ──
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Auth"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["Chat"])
app.include_router(health.router, prefix="/api/v1/health", tags=["Health"])
app.include_router(fitness.router, prefix="/api/v1/fitness", tags=["Fitness"])
app.include_router(reminders.router, prefix="/api/v1/reminders", tags=["Reminders"])
app.include_router(environment.router, prefix="/api/v1/environment", tags=["Environment"])
