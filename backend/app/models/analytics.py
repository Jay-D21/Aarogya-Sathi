from sqlalchemy import Column, String, Integer, Boolean, DateTime, Date, Numeric, Text, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class UserAnalytics(Base):
    __tablename__ = "user_analytics"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    date = Column(Date, nullable=False)
    
    total_messages_sent = Column(Integer, server_default="0")
    total_health_records_logged = Column(Integer, server_default="0")
    total_alerts_received = Column(Integer, server_default="0")
    
    app_open_count = Column(Integer, server_default="0")
    active_duration_minutes = Column(Integer, server_default="0")
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

class APIUsage(Base):
    __tablename__ = "api_usage"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    
    endpoint_path = Column(String, nullable=False)
    http_method = Column(String, nullable=False)
    
    model_used = Column(String)
    input_tokens = Column(Integer)
    output_tokens = Column(Integer)
    total_tokens = Column(Integer)
    
    estimated_cost_inr = Column(Numeric(10, 4))
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

class UserFeedback(Base):
    __tablename__ = "user_feedback"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    
    reference_type = Column(String)
    reference_id = Column(UUID)
    
    rating = Column(Integer)
    feedback_text = Column(Text)
    
    admin_response = Column(Text)
    status = Column(String, server_default="open") # ENUM
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    resolved_at = Column(DateTime)
