from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, Numeric, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class EnvironmentalAlert(Base):
    __tablename__ = "environmental_alerts"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    
    alert_type = Column(String, nullable=False) # ENUM
    alert_severity = Column(String, nullable=False) # ENUM
    alert_title = Column(String, nullable=False)
    alert_description = Column(Text, nullable=False)
    
    location_city = Column(String)
    aqi_value = Column(Integer)
    temperature_celsius = Column(Numeric(4, 1))
    triggering_metric = Column(String)
    triggering_value = Column(Numeric)
    
    is_read = Column(Boolean, server_default="false")
    action_taken = Column(Boolean, server_default="false")
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
