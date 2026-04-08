from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import APIResponse
from app.schemas.fitness import ReminderCreateRequest, ReminderUpdateRequest, AdherenceLogRequest
from app.services import reminder_service

router = APIRouter()


@router.post("/", response_model=APIResponse)
async def create_reminder(
    data: ReminderCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new reminder."""
    result = await reminder_service.create_reminder(db, current_user.id, data)
    return APIResponse(data=result.model_dump(), message="Reminder created")


@router.get("/", response_model=APIResponse)
async def list_reminders(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all reminders."""
    reminders = await reminder_service.list_reminders(db, current_user.id)
    return APIResponse(data=[r.model_dump() for r in reminders])


@router.put("/{reminder_id}", response_model=APIResponse)
async def update_reminder(
    reminder_id: str,
    data: ReminderUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update a reminder."""
    result = await reminder_service.update_reminder(db, current_user.id, reminder_id, data)
    if not result:
        return APIResponse(status="error", message="Reminder not found")
    return APIResponse(data=result.model_dump(), message="Reminder updated")


@router.delete("/{reminder_id}", response_model=APIResponse)
async def delete_reminder(
    reminder_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Soft-delete a reminder."""
    success = await reminder_service.delete_reminder(db, current_user.id, reminder_id)
    if not success:
        return APIResponse(status="error", message="Reminder not found")
    return APIResponse(message="Reminder deleted")


@router.get("/today", response_model=APIResponse)
async def today_schedule(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get today's scheduled reminders."""
    reminders = await reminder_service.get_today_schedule(db, current_user.id)
    return APIResponse(data=[r.model_dump() for r in reminders])
