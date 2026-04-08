from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import APIResponse
from app.schemas.health import BPReadingRequest, SugarReadingRequest, SymptomLogRequest, WeightLogRequest
from app.services import health_service

router = APIRouter()


@router.post("/bp-reading", response_model=APIResponse)
async def log_bp(
    data: BPReadingRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Log a blood pressure reading with ICMR classification."""
    result = await health_service.log_bp(db, current_user.id, data)
    return APIResponse(data=result.model_dump(mode="json"), message="BP reading logged")


@router.post("/sugar-reading", response_model=APIResponse)
async def log_sugar(
    data: SugarReadingRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Log a blood sugar reading with ICMR classification."""
    result = await health_service.log_sugar(db, current_user.id, data)
    return APIResponse(data=result.model_dump(mode="json"), message="Sugar reading logged")


@router.post("/symptom-log", response_model=APIResponse)
async def log_symptoms(
    data: SymptomLogRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Log symptoms with severity."""
    result = await health_service.log_symptom(db, current_user.id, data)
    return APIResponse(data=result.model_dump(mode="json"), message="Symptoms logged")


@router.post("/weight", response_model=APIResponse)
async def log_weight(
    data: WeightLogRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Log weight with BMI calculation."""
    result = await health_service.log_weight(db, current_user.id, data)
    return APIResponse(data=result.model_dump(mode="json"), message="Weight logged")


@router.get("/records", response_model=APIResponse)
async def get_records(
    record_type: str = Query(None),
    days: int = Query(30, ge=1, le=365),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get health records with optional filters."""
    records = await health_service.get_records(db, current_user.id, record_type, days, limit, offset)
    return APIResponse(data=[r.model_dump(mode="json") for r in records])


@router.get("/trends", response_model=APIResponse)
async def get_trends(
    metric: str = Query(..., pattern="^(blood_pressure|weight|sugar)$"),
    days: int = Query(90, ge=7, le=365),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get trend data for a specific health metric."""
    result = await health_service.get_trends(db, current_user.id, metric, days)
    return APIResponse(data=result.model_dump(mode="json"))
