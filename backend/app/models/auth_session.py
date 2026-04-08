from sqlalchemy import Column, String, Boolean, DateTime, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class AuthSession(Base):
    __tablename__ = "auth_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    
    refresh_token = Column(String, unique=True, nullable=False)
    device_id = Column(String)
    device_name = Column(String)
    ip_address = Column(String)
    
    expires_at = Column(DateTime, nullable=False)
    is_active = Column(Boolean, server_default="true")
    logged_out_at = Column(DateTime)
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
