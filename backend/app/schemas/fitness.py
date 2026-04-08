from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import date, datetime


# ── Fitness Schemas ──
class StepsLogRequest(BaseModel):
    steps_count: int = Field(..., ge=0, le=200000)
    log_date: date
    distance_km: Optional[float] = None


class WorkoutLogRequest(BaseModel):
    workout_type: str
    start_time: datetime
    end_time: datetime
    intensity: str = Field("moderate", pattern="^(low|moderate|high)$")
    calories_burned: Optional[int] = None
    notes: Optional[str] = None


class SleepLogRequest(BaseModel):
    sleep_hours: float = Field(..., ge=0, le=24)
    sleep_quality: int = Field(..., ge=1, le=5)
    bedtime: Optional[datetime] = None
    wake_time: Optional[datetime] = None


class WaterLogRequest(BaseModel):
    water_ml: int = Field(..., ge=0, le=10000)


class FitnessSummaryResponse(BaseModel):
    date: str
    steps: int = 0
    step_goal: int = 10000
    calories_total: int = 0
    calories_bmr: int = 0
    calories_activity: int = 0
    workouts: List[Dict[str, Any]] = []
    sleep_hours: Optional[float] = None
    water_ml: int = 0
    water_goal_ml: int = 3000


# ── Reminder Schemas ──
class ReminderCreateRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    category: str = Field(..., pattern="^(medication|water|meal|custom)$")
    reminder_time: str  # HH:MM format
    active_days: Optional[List[str]] = None  # e.g. ["Mon", "Tue", ...]


class ReminderUpdateRequest(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    reminder_time: Optional[str] = None
    active_days: Optional[List[str]] = None
    is_active: Optional[bool] = None


class ReminderResponse(BaseModel):
    id: str
    title: str
    category: str
    reminder_time: str
    active_days: Optional[List[str]] = None
    is_active: bool = True

    class Config:
        from_attributes = True


class AdherenceLogRequest(BaseModel):
    status: str = Field(..., pattern="^(done|skipped|snoozed)$")
