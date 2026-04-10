from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, Enum, text, ARRAY, Time, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database import Base

# Match DB ENUM: CREATE TYPE reminder_category AS ENUM ('medication', 'water', 'meal', 'custom');
reminder_cat_enum = Enum("medication", "water", "meal", "custom", name="reminder_category", create_type=False)

class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    title = Column(String(255), nullable=False)
    description = Column(Text)
    category = Column(reminder_cat_enum, nullable=False)

    reminder_time = Column(Time, nullable=False)
    frequency = Column(String(50), nullable=False)
    active_days = Column(ARRAY(Integer))

    is_active = Column(Boolean, server_default="true")
    last_triggered_at = Column(DateTime)

    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    # Relationships
    user = relationship("User", backref="reminders")
