"""Reminder service — CRUD operations for health reminders."""

from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.reminder import Reminder
from app.schemas.fitness import ReminderCreateRequest, ReminderUpdateRequest, ReminderResponse


async def create_reminder(db: AsyncSession, user_id, data: ReminderCreateRequest) -> ReminderResponse:
    """Create a new reminder."""
    reminder = Reminder(
        user_id=user_id,
        title=data.title,
        description=data.description,
        category=data.category,
        reminder_time=data.reminder_time,
        active_days=data.active_days or ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    )
    db.add(reminder)
    await db.commit()
    await db.refresh(reminder)

    return ReminderResponse(
        id=str(reminder.id),
        title=reminder.title,
        category=reminder.category,
        reminder_time=reminder.reminder_time,
        active_days=reminder.active_days,
        is_active=reminder.is_active,
    )


async def list_reminders(db: AsyncSession, user_id) -> list:
    """List all reminders for a user."""
    result = await db.execute(
        select(Reminder).where(Reminder.user_id == user_id).order_by(Reminder.reminder_time)
    )
    reminders = result.scalars().all()
    return [
        ReminderResponse(
            id=str(r.id),
            title=r.title,
            category=r.category,
            reminder_time=r.reminder_time,
            active_days=r.active_days,
            is_active=r.is_active,
        )
        for r in reminders
    ]


async def update_reminder(db: AsyncSession, user_id, reminder_id: str, data: ReminderUpdateRequest):
    """Update a reminder."""
    result = await db.execute(
        select(Reminder).where(Reminder.id == reminder_id, Reminder.user_id == user_id)
    )
    reminder = result.scalar_one_or_none()
    if not reminder:
        return None

    if data.title is not None:
        reminder.title = data.title
    if data.description is not None:
        reminder.description = data.description
    if data.category is not None:
        reminder.category = data.category
    if data.reminder_time is not None:
        reminder.reminder_time = data.reminder_time
    if data.active_days is not None:
        reminder.active_days = data.active_days
    if data.is_active is not None:
        reminder.is_active = data.is_active

    await db.commit()
    await db.refresh(reminder)

    return ReminderResponse(
        id=str(reminder.id),
        title=reminder.title,
        category=reminder.category,
        reminder_time=reminder.reminder_time,
        active_days=reminder.active_days,
        is_active=reminder.is_active,
    )


async def delete_reminder(db: AsyncSession, user_id, reminder_id: str) -> bool:
    """Soft-delete a reminder (set is_active=False)."""
    result = await db.execute(
        select(Reminder).where(Reminder.id == reminder_id, Reminder.user_id == user_id)
    )
    reminder = result.scalar_one_or_none()
    if not reminder:
        return False
    reminder.is_active = False
    await db.commit()
    return True


async def get_today_schedule(db: AsyncSession, user_id) -> list:
    """Get today's scheduled reminders."""
    import calendar
    today_name = calendar.day_abbr[datetime.now().weekday()]  # Mon, Tue, etc.

    result = await db.execute(
        select(Reminder).where(
            Reminder.user_id == user_id,
            Reminder.is_active == True,
        ).order_by(Reminder.reminder_time)
    )
    reminders = result.scalars().all()

    # Filter by active_days containing today
    return [
        ReminderResponse(
            id=str(r.id),
            title=r.title,
            category=r.category,
            reminder_time=r.reminder_time,
            active_days=r.active_days,
            is_active=r.is_active,
        )
        for r in reminders
        if r.active_days is None or today_name in r.active_days
    ]
