from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, Numeric, text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from app.database import Base

class ChatHistory(Base):
    __tablename__ = "chat_history"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), nullable=False)

    user_message = Column(Text, nullable=False)
    ai_response = Column(Text, nullable=False)

    environmental_context = Column(JSONB)
    user_health_context = Column(JSONB)

    model_used = Column(String(50), server_default="gemini-2.0-flash")
    response_time_ms = Column(Integer)
    tokens_used = Column(Integer)
    temperature = Column(Numeric(2, 1))

    message_language = Column(String(10))
    was_voice_input = Column(Boolean, server_default="false")
    was_voice_output = Column(Boolean, server_default="false")

    user_satisfaction_rating = Column(Integer)  # rating_domain in DB
    is_medically_accurate = Column(Boolean)
    feedback_text = Column(Text)

    contained_emergency_keywords = Column(Boolean, server_default="false")
    contained_diagnosis_claim = Column(Boolean, server_default="false")
    contained_prescription = Column(Boolean, server_default="false")
    safety_check_passed = Column(Boolean, server_default="true")

    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    deleted_at = Column(DateTime)
