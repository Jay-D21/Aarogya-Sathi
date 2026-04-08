"""Chat service — orchestrates Gemini AI, safety pipeline, and database persistence."""

from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.user import User
from app.models.chat import ChatHistory
from app.models.health_record import HealthRecord
from app.models.health_condition import HealthCondition
from app.schemas.chat import ChatMessageRequest, ChatMessageResponse
from app.services import gemini_service
from app.services.safety_service import check_safety


async def _get_health_context(db: AsyncSession, user: User) -> dict:
    """Fetch latest health data for context injection into Gemini prompt."""
    context = {}

    # Latest BP
    result = await db.execute(
        select(HealthRecord)
        .where(
            HealthRecord.user_id == user.id,
            HealthRecord.blood_pressure_systolic.is_not(None),
        )
        .order_by(HealthRecord.recorded_at.desc())
        .limit(1)
    )
    bp_record = result.scalar_one_or_none()
    if bp_record:
        context["latest_bp"] = f"{bp_record.blood_pressure_systolic}/{bp_record.blood_pressure_diastolic}"

    # Latest Sugar
    result = await db.execute(
        select(HealthRecord)
        .where(
            HealthRecord.user_id == user.id,
            HealthRecord.blood_sugar_random.is_not(None),
        )
        .order_by(HealthRecord.recorded_at.desc())
        .limit(1)
    )
    sugar_record = result.scalar_one_or_none()
    if sugar_record:
        context["latest_sugar"] = f"{sugar_record.blood_sugar_random} mg/dL"

    # Active conditions
    result = await db.execute(
        select(HealthCondition.condition_name).where(
            HealthCondition.user_id == user.id,
            HealthCondition.condition_status == "active",
        )
    )
    conditions = result.scalars().all()
    if conditions:
        context["conditions"] = ", ".join(conditions)

    # BMI
    if user.height_cm:
        weight_result = await db.execute(
            select(HealthRecord.weight_kg)
            .where(
                HealthRecord.user_id == user.id,
                HealthRecord.weight_kg.is_not(None),
            )
            .order_by(HealthRecord.recorded_at.desc())
            .limit(1)
        )
        weight = weight_result.scalar_one_or_none()
        if weight and float(user.height_cm) > 0:
            height_m = float(user.height_cm) / 100
            bmi = round(float(weight) / (height_m * height_m), 1)
            context["bmi"] = str(bmi)

    return context


async def process_chat_message(
    db: AsyncSession, user: User, data: ChatMessageRequest
) -> ChatMessageResponse:
    """Full chat pipeline: context → Gemini → safety → save → return."""

    # 1. Get health context
    health_context = await _get_health_context(db, user)

    # 2. Get environment context (placeholder — will be connected in Part 10)
    env_context = None
    if data.include_environmental_context and user.preferred_city:
        env_context = {"city": user.preferred_city}

    # 3. Call Gemini
    ai_result = await gemini_service.get_ai_response(
        message=data.message,
        health_context=health_context if health_context else None,
        env_context=env_context,
    )

    # 4. Run safety pipeline
    safety_result = check_safety(ai_result["response"], data.message)

    # 5. Save to database
    chat_record = ChatHistory(
        user_id=user.id,
        user_message=data.message,
        ai_response=safety_result["safe_response"],
        language=data.language,
        environmental_context=env_context,
        health_context_used=bool(health_context),
        safety_check_passed=safety_result["safety_passed"],
        contained_medical_advice=True,
        contained_prescription_claim=safety_result["prescription_claim"],
        contained_diagnosis_claim=safety_result["diagnosis_claim"],
        contained_emergency_keywords=safety_result["emergency"],
        tokens_used=ai_result.get("tokens_used", 0),
        response_time_ms=ai_result.get("response_time_ms", 0),
        model_used=ai_result.get("model", "gemini-2.0-flash"),
    )
    db.add(chat_record)
    await db.commit()
    await db.refresh(chat_record)

    return ChatMessageResponse(
        chat_id=str(chat_record.id),
        user_message=data.message,
        ai_response=safety_result["safe_response"],
        timestamp=chat_record.created_at or datetime.now(timezone.utc),
        response_time_ms=ai_result.get("response_time_ms", 0),
        tokens_used=ai_result.get("tokens_used", 0),
        environmental_context=env_context,
        safety_flags={
            "diagnosis_claim": safety_result["diagnosis_claim"],
            "prescription_claim": safety_result["prescription_claim"],
            "emergency": safety_result["emergency"],
            "safety_passed": safety_result["safety_passed"],
        },
    )


async def get_chat_history(
    db: AsyncSession, user_id: str, limit: int = 50, offset: int = 0
) -> dict:
    """Fetch paginated chat history for a user."""
    # Count total
    count_result = await db.execute(
        select(func.count()).select_from(ChatHistory).where(ChatHistory.user_id == user_id)
    )
    total = count_result.scalar()

    # Fetch messages
    result = await db.execute(
        select(ChatHistory)
        .where(ChatHistory.user_id == user_id)
        .order_by(ChatHistory.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    messages = result.scalars().all()

    return {
        "total": total,
        "limit": limit,
        "offset": offset,
        "messages": [
            ChatMessageResponse(
                chat_id=str(m.id),
                user_message=m.user_message,
                ai_response=m.ai_response,
                timestamp=m.created_at or datetime.now(timezone.utc),
                response_time_ms=m.response_time_ms or 0,
                tokens_used=m.tokens_used or 0,
            )
            for m in messages
        ],
    }


async def rate_chat(db: AsyncSession, user_id: str, chat_id: str, rating: int, feedback: str = None):
    """Save user rating/feedback for a chat message."""
    result = await db.execute(
        select(ChatHistory).where(ChatHistory.id == chat_id, ChatHistory.user_id == user_id)
    )
    chat = result.scalar_one_or_none()
    if not chat:
        return None
    chat.user_rating = rating
    chat.user_feedback = feedback
    await db.commit()
    return {"chat_id": chat_id, "rating": rating}
