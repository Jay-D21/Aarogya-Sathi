from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, JSON, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class ChatHistory(Base):
    __tablename__ = "chat_history"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    
    user_message = Column(Text, nullable=False)
    ai_response = Column(Text, nullable=False)
    language = Column(String, server_default="en")
    
    environmental_context = Column(JSON)
    health_context_used = Column(Boolean, server_default="false")
    
    safety_check_passed = Column(Boolean, nullable=False)
    contained_medical_advice = Column(Boolean, server_default="true")
    contained_prescription_claim = Column(Boolean, server_default="false")
    contained_diagnosis_claim = Column(Boolean, server_default="false")
    contained_emergency_keywords = Column(Boolean, server_default="false")
    
    tokens_used = Column(Integer, server_default="0")
    response_time_ms = Column(Integer, server_default="0")
    model_used = Column(String, server_default="gemini-2.0-flash")
    
    user_rating = Column(Integer)
    user_feedback = Column(Text)
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
