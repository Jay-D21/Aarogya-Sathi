"""Fitness service — steps, workouts, sleep, water, calorie estimation."""

from datetime import date, datetime, timezone, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.fitness import DailySteps, Workout
from app.models.health_record import HealthRecord
from app.models.user import User
from app.models.preferences import UserPreference


async def log_steps(db: AsyncSession, user_id, steps_count: int, log_date: date, distance_km: float = None):
    """Upsert daily steps."""
    result = await db.execute(
        select(DailySteps).where(DailySteps.user_id == user_id, DailySteps.log_date == log_date)
    )
    existing = result.scalar_one_or_none()

    if existing:
        existing.steps_count = steps_count
        if distance_km:
            existing.distance_km = distance_km
        existing.calories_burned = int(steps_count * 0.04)
    else:
        step_record = DailySteps(
            user_id=user_id,
            log_date=log_date,
            steps_count=steps_count,
            distance_km=distance_km,
            calories_burned=int(steps_count * 0.04),
        )
        db.add(step_record)

    await db.commit()
    return {"steps_count": steps_count, "log_date": str(log_date), "calories_burned": int(steps_count * 0.04)}


async def log_workout(db: AsyncSession, user_id, data):
    """Log a workout session."""
    duration = int((data.end_time - data.start_time).total_seconds() / 60)

    # Estimate calories if not provided
    calories = data.calories_burned
    if not calories:
        met_values = {"low": 3, "moderate": 5, "high": 8}
        met = met_values.get(data.intensity, 5)
        # Try to get user's latest weight for accurate calorie estimation
        weight_kg = 70.0  # default
        weight_result = await db.execute(
            select(HealthRecord.weight_kg)
            .where(HealthRecord.user_id == user_id, HealthRecord.weight_kg.is_not(None))
            .order_by(HealthRecord.recorded_at.desc())
            .limit(1)
        )
        latest_weight = weight_result.scalar_one_or_none()
        if latest_weight:
            weight_kg = float(latest_weight)
        calories = int(met * weight_kg * (duration / 60))

    workout = Workout(
        user_id=user_id,
        workout_type=data.workout_type,
        start_time=data.start_time,
        end_time=data.end_time,
        duration_minutes=duration,
        calories_burned=calories,
        intensity=data.intensity,
        notes=data.notes,
    )
    db.add(workout)
    await db.commit()
    await db.refresh(workout)

    return {
        "workout_id": str(workout.id),
        "workout_type": data.workout_type,
        "duration_minutes": duration,
        "calories_burned": calories,
    }


async def log_sleep(db: AsyncSession, user_id, sleep_hours: float, sleep_quality: int):
    """Log sleep data as a health record."""
    record = HealthRecord(
        user_id=user_id,
        record_type="vitals",
        sleep_hours=sleep_hours,
        sleep_quality=str(sleep_quality), # Store as string to match model
        notes=f"Sleep: {sleep_hours} hours, Quality: {sleep_quality}/5",
        recorded_at=datetime.now(timezone.utc),
    )
    db.add(record)
    await db.commit()
    return {"sleep_hours": sleep_hours, "sleep_quality": sleep_quality}


async def log_water(db: AsyncSession, user_id, water_ml: int):
    """Log water intake."""
    record = HealthRecord(
        user_id=user_id,
        record_type="vitals",
        water_intake_liters=water_ml / 1000.0,
        notes=f"Water intake: {water_ml}ml",
        recorded_at=datetime.now(timezone.utc),
    )
    db.add(record)
    await db.commit()
    return {"water_ml": water_ml}


async def get_daily_summary(db: AsyncSession, user_id, target_date: date) -> dict:
    """Get comprehensive daily fitness summary."""
    # Get user for BMR calculation
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    # Steps
    step_result = await db.execute(
        select(DailySteps).where(DailySteps.user_id == user_id, DailySteps.log_date == target_date)
    )
    step_record = step_result.scalar_one_or_none()
    steps = step_record.steps_count if step_record else 0

    # Step goal
    pref_result = await db.execute(select(UserPreference).where(UserPreference.user_id == user_id))
    prefs = pref_result.scalar_one_or_none()
    step_goal = prefs.target_daily_steps if prefs else 10000

    # Workouts today
    start_of_day = datetime.combine(target_date, datetime.min.time()).replace(tzinfo=timezone.utc)
    end_of_day = start_of_day + timedelta(days=1)
    workout_result = await db.execute(
        select(Workout).where(
            Workout.user_id == user_id,
            Workout.start_time >= start_of_day,
            Workout.start_time < end_of_day,
        )
    )
    workouts = workout_result.scalars().all()
    workout_calories = sum(w.calories_burned or 0 for w in workouts)

    # Latest weight for BMR
    weight_kg = 70.0
    weight_result = await db.execute(
        select(HealthRecord.weight_kg)
        .where(HealthRecord.user_id == user_id, HealthRecord.weight_kg.is_not(None))
        .order_by(HealthRecord.recorded_at.desc())
        .limit(1)
    )
    latest_weight = weight_result.scalar_one_or_none()
    if latest_weight:
        weight_kg = float(latest_weight)

    # BMR estimate (Mifflin-St Jeor)
    height_cm = float(user.height_cm) if user and user.height_cm else 170.0
    age = 30 # default
    if user and user.date_of_birth:
        age = (date.today() - user.date_of_birth).days // 365
    
    if user and user.gender == 'female':
        bmr = (10 * weight_kg) + (6.25 * height_cm) - (5 * age) - 161
    else:
        bmr = (10 * weight_kg) + (6.25 * height_cm) - (5 * age) + 5
        
    activity_calories = int(steps * 0.04)
    total_calories = int(bmr) + activity_calories + workout_calories

    # Water estimate
    water_result = await db.execute(
        select(func.sum(HealthRecord.water_intake_liters))
        .where(
            HealthRecord.user_id == user_id,
            HealthRecord.record_type == "vitals",
            HealthRecord.recorded_at >= start_of_day,
            HealthRecord.recorded_at < end_of_day,
        )
    )
    total_water_liters = water_result.scalar_one_or_none() or 0
    water_ml = int(total_water_liters * 1000)

    # Sleep estimate
    sleep_result = await db.execute(
        select(func.sum(HealthRecord.sleep_hours))
        .where(
            HealthRecord.user_id == user_id,
            HealthRecord.record_type == "vitals",
            HealthRecord.recorded_at >= start_of_day,
            HealthRecord.recorded_at < end_of_day,
        )
    )
    total_sleep_hours = float(sleep_result.scalar_one_or_none() or 0)

    return {
        "date": str(target_date),
        "steps": steps,
        "step_goal": step_goal,
        "calories_total": total_calories,
        "calories_bmr": int(bmr),
        "calories_activity": activity_calories + workout_calories,
        "sleep_hours": total_sleep_hours if total_sleep_hours > 0 else None,
        "water_ml": water_ml,
        "water_goal_ml": prefs.target_daily_water_liters * 1000 if prefs and hasattr(prefs, 'target_daily_water_liters') else 3000,
        "workouts": [
            {"type": w.workout_type, "duration": w.duration_minutes, "calories": w.calories_burned}
            for w in workouts
        ],
    }


async def get_step_history(db: AsyncSession, user_id, days: int = 30) -> list:
    """Get step history for the last N days."""
    cutoff = date.today() - timedelta(days=days)
    result = await db.execute(
        select(DailySteps)
        .where(DailySteps.user_id == user_id, DailySteps.log_date >= cutoff)
        .order_by(DailySteps.log_date.desc())
    )
    records = result.scalars().all()
    return [
        {"date": str(r.log_date), "steps": r.steps_count, "calories": r.calories_burned or 0}
        for r in records
    ]
