from sqlalchemy import Column, String, Integer, Boolean, DateTime, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class UserPreference(Base):
    __tablename__ = "user_preferences"

    user_id = Column(UUID(as_uuid=True), primary_key=True)
    
    notifications_enabled = Column(Boolean, server_default="true")
    daily_reminder_time = Column(String, server_default="09:00:00")
    
    target_daily_steps = Column(Integer, server_default="10000")
    target_sleep_hours = Column(Integer, server_default="8")
    target_water_liters = Column(Integer, server_default="3")
    
    theme_preference = Column(String, server_default="system")
    voice_output_enabled = Column(Boolean, server_default="true")
    voice_gender = Column(String, server_default="female")
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
