"""Health tracking service — BP, sugar, symptoms, weight with ICMR classification."""

from datetime import datetime, timezone, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.health_record import HealthRecord
from app.models.user import User
from app.schemas.health import (
    BPReadingRequest, SugarReadingRequest, SymptomLogRequest, WeightLogRequest,
    HealthRecordResponse, HealthTrendResponse,
)
from app.utils.icmr import classify_bp, classify_sugar, classify_bmi
import json


async def log_bp(db: AsyncSession, user_id, data: BPReadingRequest) -> HealthRecordResponse:
    """Log blood pressure reading with ICMR classification."""
    classification = classify_bp(data.systolic, data.diastolic)

    record = HealthRecord(
        user_id=user_id,
        record_type="vitals",
        blood_pressure_systolic=data.systolic,
        blood_pressure_diastolic=data.diastolic,
        heart_rate=data.heart_rate,
        notes=data.notes,
        recorded_at=data.measured_at,
    )
    db.add(record)
    await db.commit()
    await db.refresh(record)

    return HealthRecordResponse(
        record_id=str(record.id),
        record_type="vitals",
        values={"systolic": data.systolic, "diastolic": data.diastolic, "heart_rate": data.heart_rate},
        status=classification,
        recorded_at=record.recorded_at,
    )


async def log_sugar(db: AsyncSession, user_id, data: SugarReadingRequest) -> HealthRecordResponse:
    """Log blood sugar reading with ICMR classification."""
    classification = classify_sugar(data.glucose_value, data.reading_type)

    record = HealthRecord(
        user_id=user_id,
        record_type="vitals",
        blood_sugar_fasting=data.glucose_value if data.reading_type == "fasting" else None,
        blood_sugar_random=data.glucose_value if data.reading_type == "random" else None,
        blood_sugar_pp=data.glucose_value if data.reading_type == "post_meal" else None,
        notes=data.notes,
        recorded_at=data.measured_at,
    )
    db.add(record)
    await db.commit()
    await db.refresh(record)

    return HealthRecordResponse(
        record_id=str(record.id),
        record_type="vitals",
        values={"glucose_value": data.glucose_value, "reading_type": data.reading_type},
        status=classification,
        recorded_at=record.recorded_at,
    )


async def log_symptom(db: AsyncSession, user_id, data: SymptomLogRequest) -> HealthRecordResponse:
    """Log symptoms."""
    # Allow specifying time if we want to add it to schema later
    measured_at = getattr(data, 'measured_at', datetime.now(timezone.utc))
    
    record = HealthRecord(
        user_id=user_id,
        record_type="symptom",
        symptom_description=", ".join(data.symptoms) if data.symptoms else None,
        symptom_severity=data.severity,
        symptom_duration=data.duration,
        notes=data.notes,
        recorded_at=measured_at,
    )
    db.add(record)
    await db.commit()
    await db.refresh(record)

    return HealthRecordResponse(
        record_id=str(record.id),
        record_type="symptom",
        values={"symptoms": data.symptoms, "severity": data.severity},
        recorded_at=record.recorded_at,
    )


async def log_weight(db: AsyncSession, user_id, data: WeightLogRequest) -> HealthRecordResponse:
    """Log weight and calculate BMI."""
    # Get user height for BMI
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    bmi_info = None
    if user and user.height_cm and float(user.height_cm) > 0:
        bmi_info = classify_bmi(data.weight_kg, float(user.height_cm))

    record = HealthRecord(
        user_id=user_id,
        record_type="vitals",
        weight_kg=data.weight_kg,
        recorded_at=data.measured_at,
    )
    db.add(record)
    await db.commit()
    await db.refresh(record)

    values = {"weight_kg": data.weight_kg}
    if bmi_info:
        values["bmi"] = bmi_info["bmi"]
        values["bmi_status"] = bmi_info["status"]

    return HealthRecordResponse(
        record_id=str(record.id),
        record_type="vitals",
        values=values,
        status=bmi_info if bmi_info else None,
        recorded_at=record.recorded_at,
    )


async def get_records(
    db: AsyncSession, user_id, record_type: str = None, days: int = 30, limit: int = 50, offset: int = 0
) -> list:
    """Get health records with optional filters."""
    query = select(HealthRecord).where(HealthRecord.user_id == user_id)

    if record_type:
        query = query.where(HealthRecord.record_type == record_type)

    cutoff = datetime.now(timezone.utc) - timedelta(days=days)
    query = query.where(HealthRecord.recorded_at >= cutoff)
    query = query.order_by(HealthRecord.recorded_at.desc()).limit(limit).offset(offset)

    result = await db.execute(query)
    records = result.scalars().all()

    return [
        HealthRecordResponse(
            record_id=str(r.id),
            record_type=r.record_type,
            values={
                "systolic": r.blood_pressure_systolic,
                "diastolic": r.blood_pressure_diastolic,
                "heart_rate": r.heart_rate,
                "sugar_fasting": r.blood_sugar_fasting,
                "sugar_random": r.blood_sugar_random,
                "weight_kg": float(r.weight_kg) if r.weight_kg else None,
                "sleep_hours": float(r.sleep_hours) if r.sleep_hours else None,
                "sleep_quality": int(r.sleep_quality) if r.sleep_quality and str(r.sleep_quality).isdigit() else None,
                "water_intake_liters": float(r.water_intake_liters) if r.water_intake_liters else None,
            },
            recorded_at=r.recorded_at,
        )
        for r in records
    ]


async def get_trends(db: AsyncSession, user_id, metric: str, days: int = 90) -> HealthTrendResponse:
    """Get trend data for a health metric."""
    cutoff = datetime.now(timezone.utc) - timedelta(days=days)

    if metric == "blood_pressure":
        result = await db.execute(
            select(
                func.date(HealthRecord.recorded_at).label("date"),
                func.avg(HealthRecord.blood_pressure_systolic).label("avg_sys"),
                func.avg(HealthRecord.blood_pressure_diastolic).label("avg_dia"),
            )
            .where(
                HealthRecord.user_id == user_id,
                HealthRecord.blood_pressure_systolic.is_not(None),
                HealthRecord.recorded_at >= cutoff,
            )
            .group_by(func.date(HealthRecord.recorded_at))
            .order_by(func.date(HealthRecord.recorded_at))
        )
        rows = result.all()
        trend_data = [
            {"date": str(r.date), "avg_systolic": round(float(r.avg_sys), 1), "avg_diastolic": round(float(r.avg_dia), 1)}
            for r in rows
        ]
        all_sys = [d["avg_systolic"] for d in trend_data]
        stats = {
            "avg": round(sum(all_sys) / len(all_sys), 1) if all_sys else 0,
            "min": min(all_sys) if all_sys else 0,
            "max": max(all_sys) if all_sys else 0,
            "data_points": len(trend_data),
        }
    elif metric == "weight":
        result = await db.execute(
            select(
                func.date(HealthRecord.recorded_at).label("date"),
                func.avg(HealthRecord.weight_kg).label("avg_weight"),
            )
            .where(
                HealthRecord.user_id == user_id,
                HealthRecord.weight_kg.is_not(None),
                HealthRecord.recorded_at >= cutoff,
            )
            .group_by(func.date(HealthRecord.recorded_at))
            .order_by(func.date(HealthRecord.recorded_at))
        )
        rows = result.all()
        trend_data = [{"date": str(r.date), "avg_weight": round(float(r.avg_weight), 1)} for r in rows]
        all_w = [d["avg_weight"] for d in trend_data]
        stats = {
            "avg": round(sum(all_w) / len(all_w), 1) if all_w else 0,
            "min": min(all_w) if all_w else 0,
            "max": max(all_w) if all_w else 0,
            "data_points": len(trend_data),
        }
    else:
        trend_data = []
        stats = {"data_points": 0}

    return HealthTrendResponse(metric=metric, period_days=days, trend_data=trend_data, statistics=stats)
