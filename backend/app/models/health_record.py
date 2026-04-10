from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, Numeric, ARRAY, Enum, text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from app.database import Base

# Match DB ENUM: CREATE TYPE health_record_type AS ENUM ('symptom', 'vitals', 'medical_report', 'medication', 'lifestyle');
record_type_enum = Enum("symptom", "vitals", "medical_report", "medication", "lifestyle", name="health_record_type", create_type=False)

class HealthRecord(Base):
    __tablename__ = "health_records"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    record_type = Column(record_type_enum, nullable=False)

    symptom_description = Column(Text)
    symptom_severity = Column(Integer)  # severity_domain in DB
    symptom_duration = Column(String(100))
    symptom_triggers = Column(JSONB)

    blood_pressure_systolic = Column(Integer)  # bp_reading domain
    blood_pressure_diastolic = Column(Integer)  # bp_reading domain
    heart_rate = Column(Integer)

    blood_sugar_fasting = Column(Integer)  # sugar_reading domain
    blood_sugar_random = Column(Integer)  # sugar_reading domain
    blood_sugar_pp = Column(Integer)  # sugar_reading domain

    weight_kg = Column(Numeric(5, 2))
    height_cm = Column(Numeric(5, 2))
    temperature_celsius = Column(Numeric(4, 1))

    sleep_hours = Column(Numeric(3, 1))
    sleep_quality = Column(String(50))
    stress_level = Column(Integer)  # severity_domain
    activity_level = Column(String(50))
    exercise_minutes = Column(Integer)
    water_intake_liters = Column(Numeric(3, 1))
    alcohol_units = Column(Integer)
    smoking_status = Column(String(50))

    environmental_context = Column(JSONB)
    food_items = Column(ARRAY(Text))
    medications_taken = Column(ARRAY(Text))

    recorded_location_city = Column(String(100))
    recorded_location_lat = Column(Numeric(10, 8))
    recorded_location_lon = Column(Numeric(11, 8))

    recorded_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    data_source = Column(String(50))
    confidence_score = Column(Numeric(3, 2))
    notes = Column(Text)

    # Relationships
    user = relationship("User", backref="health_records")


class HealthRecordAudit(Base):
    __tablename__ = "health_records_audit"

    audit_id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    record_id = Column(UUID(as_uuid=True), nullable=False)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    action_type = Column(String, nullable=False)
    old_data = Column(JSONB)
    new_data = Column(JSONB)
    changed_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    changed_by = Column(String(50), server_default="system")
