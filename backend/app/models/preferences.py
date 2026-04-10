from sqlalchemy import Column, String, Boolean, DateTime, Integer, ARRAY, Text, text, Enum, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database import Base

# Existing PostgreSQL enum
gender_enum = Enum("male", "female", "other", "prefer_not_to_say", name="user_gender", create_type=False)

class UserPreference(Base):
    __tablename__ = "user_preferences"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)

    notifications_enabled = Column(Boolean, server_default="true")
    email_notifications = Column(Boolean, server_default="true")
    push_notifications = Column(Boolean, server_default="true")
    sms_notifications = Column(Boolean, server_default="false")

    alert_aqi_threshold = Column(Integer, server_default="300")
    alert_temperature_high = Column(Integer, server_default="40")
    alert_temperature_low = Column(Integer, server_default="5")
    alert_frequency = Column(String, server_default="daily")

    voice_input_enabled = Column(Boolean, server_default="true")
    voice_output_enabled = Column(Boolean, server_default="true")
    voice_language = Column(String, server_default="hi")
    voice_gender = Column(gender_enum)

    share_health_data_government = Column(Boolean, server_default="false")
    share_health_data_research = Column(Boolean, server_default="false")
    location_tracking_enabled = Column(Boolean, server_default="true")
    analytics_enabled = Column(Boolean, server_default="true")

    dark_mode = Column(Boolean, server_default="false")
    font_size = Column(String, server_default="medium")
    units_system = Column(String, server_default="metric")

    dietary_type = Column(String)
    food_allergies = Column(ARRAY(Text))
    preferred_cuisines = Column(ARRAY(Text))
    preferred_exercise_type = Column(String)

    target_daily_steps = Column(Integer, server_default="10000")
    target_daily_exercise_minutes = Column(Integer, server_default="30")

    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    # Relationships
    user = relationship("User", backref="preferences", uselist=False)
