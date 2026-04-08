from sqlalchemy import Column, String, Boolean, DateTime, text, ARRAY
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    
    title = Column(String, nullable=False)
    description = Column(String)
    category = Column(String, nullable=False) # ENUM
    
    reminder_time = Column(String, nullable=False) # TIME 
    active_days = Column(ARRAY(String)) # TEXT[]
    
    is_active = Column(Boolean, server_default="true")
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
