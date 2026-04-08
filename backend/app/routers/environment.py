from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.environment import EnvironmentalAlert
from app.schemas.common import APIResponse
from app.services import environment_service

router = APIRouter()


@router.get("/current", response_model=APIResponse)
async def get_current(
    current_user: User = Depends(get_current_user),
):
    """Get current AQI + weather for user's city."""
    city = current_user.preferred_city or "Mumbai"
    result = await environment_service.get_current_environment(city)
    return APIResponse(data=result)


@router.get("/alerts", response_model=APIResponse)
async def get_alerts(
    limit: int = Query(10, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get user's environmental and health alerts."""
    result = await db.execute(
        select(EnvironmentalAlert)
        .where(EnvironmentalAlert.user_id == current_user.id)
        .order_by(EnvironmentalAlert.created_at.desc())
        .limit(limit)
    )
    alerts = result.scalars().all()

    return APIResponse(
        data=[
            {
                "id": str(a.id),
                "alert_type": a.alert_type,
                "severity": a.alert_severity,
                "title": a.alert_title,
                "description": a.alert_description,
                "is_read": a.is_read,
                "created_at": str(a.created_at),
            }
            for a in alerts
        ]
    )
