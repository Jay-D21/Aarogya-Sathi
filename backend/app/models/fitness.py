from sqlalchemy import Column, String, Integer, DateTime, Date, Numeric, Text, text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database import Base

class DailySteps(Base):
    __tablename__ = "daily_steps"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    log_date = Column(Date, nullable=False)

    steps_count = Column(Integer, nullable=False, server_default="0")
    distance_km = Column(Numeric(6, 2))
    calories_burned = Column(Integer)
    active_minutes = Column(Integer)
    data_source = Column(String(50))

    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    # Relationships
    user = relationship("User", backref="daily_steps_records")


class Workout(Base):
    __tablename__ = "workouts"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    workout_type = Column(String(100), nullable=False)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=False)

    duration_minutes = Column(Integer)
    intensity = Column(String(50))
    calories_burned = Column(Integer)
    avg_heart_rate = Column(Integer)
    max_heart_rate = Column(Integer)
    distance_km = Column(Numeric(6, 2))
    notes = Column(Text)

    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    # Relationships
    user = relationship("User", backref="workout_records")
