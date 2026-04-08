from sqlalchemy import Column, String, Integer, Boolean, DateTime, Date, Text, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class HealthCondition(Base):
    __tablename__ = "health_conditions"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    
    condition_name = Column(String, nullable=False)
    icd10_code = Column(String)
    diagnosed_date = Column(Date)
    
    condition_status = Column(String, server_default="active") # ENUM
    severity = Column(Integer)
    
    treatment_plan = Column(Text)
    doctor_name = Column(String)
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
