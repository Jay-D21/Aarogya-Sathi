from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime


class BPReadingRequest(BaseModel):
    systolic: int = Field(..., ge=40, le=300)
    diastolic: int = Field(..., ge=40, le=300)
    heart_rate: Optional[int] = Field(None, ge=30, le=250)
    measured_at: datetime
    notes: Optional[str] = None


class SugarReadingRequest(BaseModel):
    glucose_value: int = Field(..., ge=20, le=600)
    reading_type: str = Field(..., pattern="^(fasting|random|post_meal)$")
    measured_at: datetime
    notes: Optional[str] = None


class SymptomLogRequest(BaseModel):
    symptoms: List[str]
    severity: int = Field(..., ge=1, le=10)
    duration: Optional[str] = None
    triggers: Optional[List[str]] = None
    notes: Optional[str] = None


class WeightLogRequest(BaseModel):
    weight_kg: float = Field(..., ge=10, le=300)
    measured_at: datetime


class HealthRecordResponse(BaseModel):
    record_id: str
    record_type: str
    values: Dict[str, Any]
    status: Optional[Dict[str, str]] = None
    recorded_at: datetime


class HealthTrendResponse(BaseModel):
    metric: str
    period_days: int
    trend_data: List[Dict[str, Any]]
    statistics: Dict[str, Any]
