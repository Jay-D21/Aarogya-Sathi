from sqlalchemy import Column, String, Boolean, DateTime, Text, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class AuthSession(Base):
    __tablename__ = "auth_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), nullable=False)

    access_token = Column(String(500))
    refresh_token = Column(String(500))
    token_type = Column(String(50), server_default="Bearer")

    device_type = Column(String(50))
    device_name = Column(String(255))
    device_os = Column(String(100))
    app_version = Column(String(20))
    ip_address = Column(String(50))
    user_agent = Column(Text)

    expires_at = Column(DateTime, nullable=False)
    refresh_token_expires_at = Column(DateTime)

    is_active = Column(Boolean, server_default="true")
    last_activity_at = Column(DateTime)
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    logged_out_at = Column(DateTime)
