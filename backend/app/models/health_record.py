from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, Numeric, JSON, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class HealthRecord(Base):
    __tablename__ = "health_records"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    record_source = Column(String, server_default="manual")
    record_type = Column(String, nullable=False) # ENUM
    
    blood_pressure_systolic = Column(Integer)
    blood_pressure_diastolic = Column(Integer)
    heart_rate = Column(Integer)
    
    blood_sugar_fasting = Column(Integer)
    blood_sugar_post_prandial = Column(Integer)
    blood_sugar_random = Column(Integer)
    hba1c = Column(Numeric(4, 1))
    
    weight_kg = Column(Numeric(5, 2))
    oxygen_saturation = Column(Integer)
    body_temperature = Column(Numeric(4, 1))
    
    symptoms = Column(JSON)
    notes = Column(Text)
    environmental_context = Column(JSON)
    
    recorded_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))


class HealthRecordAudit(Base):
    __tablename__ = "health_records_audit"

    audit_id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    record_id = Column(UUID, nullable=False)
    user_id = Column(UUID, nullable=False)
    action_type = Column(String, nullable=False)
    old_data = Column(JSON)
    new_data = Column(JSON)
    changed_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
