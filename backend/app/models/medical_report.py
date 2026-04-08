from sqlalchemy import Column, String, Integer, Boolean, DateTime, Date, Text, JSON, ARRAY, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class MedicalReport(Base):
    __tablename__ = "medical_reports"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    
    report_title = Column(String, nullable=False)
    report_type = Column(String, nullable=False)
    file_path = Column(String)
    extracted_text = Column(Text)
    
    biomarkers = Column(JSON)
    ai_summary = Column(Text)
    
    is_abnormal = Column(Boolean, server_default="false")
    requires_doctor_visit = Column(Boolean, server_default="false")
    
    report_date = Column(Date)
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
