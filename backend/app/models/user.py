from sqlalchemy import Column, String, Boolean, DateTime, Date, Numeric, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    email = Column(String, unique=True, nullable=False)
    phone = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    first_name = Column(String, nullable=False)
    last_name = Column(String)
    date_of_birth = Column(Date)
    gender = Column(String) # ENUM
    height_cm = Column(Numeric)
    
    preferred_language = Column(String, server_default="en")
    timezone = Column(String, server_default="Asia/Kolkata")
    preferred_city = Column(String)
    
    abha_id = Column(String, unique=True)
    abha_linked_at = Column(DateTime)
    
    subscription_plan = Column(String, server_default="free") # ENUM
    subscription_status = Column(String, server_default="active")
    subscription_start_date = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    subscription_end_date = Column(DateTime)
    
    has_accepted_terms = Column(Boolean, server_default="true")
    terms_accepted_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    has_accepted_privacy = Column(Boolean, server_default="true")
    privacy_accepted_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    data_sharing_consent = Column(Boolean, server_default="false")
    research_consent = Column(Boolean, server_default="false")
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    last_login_at = Column(DateTime)
    is_active = Column(Boolean, server_default="true")
    is_verified = Column(Boolean, server_default="false")
    email_verified_at = Column(DateTime)
    phone_verified_at = Column(DateTime)
    deleted_at = Column(DateTime)
