from fastapi import APIRouter, Depends, Query
from datetime import date
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import APIResponse
from app.schemas.fitness import StepsLogRequest, WorkoutLogRequest, SleepLogRequest, WaterLogRequest
from app.services import fitness_service

router = APIRouter()


@router.post("/steps", response_model=APIResponse)
async def log_steps(
    data: StepsLogRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Log daily steps (upsert by date)."""
    result = await fitness_service.log_steps(db, current_user.id, data.steps_count, data.log_date, data.distance_km)
    return APIResponse(data=result, message="Steps logged")


@router.post("/workout", response_model=APIResponse)
async def log_workout(
    data: WorkoutLogRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Log a workout session."""
    result = await fitness_service.log_workout(db, current_user.id, data)
    return APIResponse(data=result, message="Workout logged")


@router.post("/sleep", response_model=APIResponse)
async def log_sleep(
    data: SleepLogRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Log sleep data."""
    result = await fitness_service.log_sleep(db, current_user.id, data.sleep_hours, data.sleep_quality)
    return APIResponse(data=result, message="Sleep logged")


@router.post("/water", response_model=APIResponse)
async def log_water(
    data: WaterLogRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Log water intake."""
    result = await fitness_service.log_water(db, current_user.id, data.water_ml)
    return APIResponse(data=result, message="Water intake logged")


@router.get("/summary", response_model=APIResponse)
async def get_summary(
    target_date: date = Query(None, alias="date"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get daily fitness summary."""
    if not target_date:
        target_date = date.today()
    result = await fitness_service.get_daily_summary(db, current_user.id, target_date)
    return APIResponse(data=result)


@router.get("/history", response_model=APIResponse)
async def get_step_history(
    days: int = Query(30, ge=1, le=365),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get step history for the last N days."""
    result = await fitness_service.get_step_history(db, current_user.id, days)
    return APIResponse(data=result)
