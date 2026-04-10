from sqlalchemy import Column, String, Integer, Boolean, DateTime, Date, Text, Numeric, ARRAY, text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from app.database import Base

class MedicalReport(Base):
    __tablename__ = "medical_reports"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    report_date = Column(Date, nullable=False)
    report_type = Column(String(100))
    test_name = Column(String(255))
    lab_name = Column(String(255))
    lab_location = Column(String(255))
    
    biomarkers = Column(JSONB)
    
    extracted_text = Column(Text)
    interpretation = Column(Text)
    key_findings = Column(ARRAY(Text))
    abnormal_values = Column(JSONB)
    health_risks = Column(JSONB)
    
    report_image_url = Column(String(500))
    report_image_s3_key = Column(String(500))
    raw_image_file_size = Column(Integer)
    
    ocr_confidence_score = Column(Numeric(3, 2))
    biomarker_extraction_confidence = Column(JSONB)
    needs_manual_review = Column(Boolean, server_default="false")
    manual_review_by_user = Column(Boolean, server_default="false")
    
    is_encrypted = Column(Boolean, server_default="true")
    encryption_key_id = Column(String(100))
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    reviewed_at = Column(DateTime)
    deleted_at = Column(DateTime)

    # Relationships
    user = relationship("User", backref="medical_reports")
