from sqlalchemy import Column, String, Integer, DateTime, Date, Numeric, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class DailySteps(Base):
    __tablename__ = "daily_steps"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    log_date = Column(Date, nullable=False)
    
    steps_count = Column(Integer, server_default="0")
    distance_km = Column(Numeric(5, 2))
    active_calories = Column(Integer)
    
    device_source = Column(String)
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

class Workout(Base):
    __tablename__ = "workouts"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    
    workout_type = Column(String, nullable=False)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=False)
    
    duration_minutes = Column(Integer)
    calories_burned = Column(Integer)
    intensity = Column(String)
    
    avg_heart_rate = Column(Integer)
    notes = Column(String)
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
