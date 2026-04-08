from sqlalchemy import Column, String, Integer, Boolean, DateTime, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class Subscription(Base):
    __tablename__ = "subscriptions"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False, unique=True)
    
    plan_type = Column(String, nullable=False) # ENUM
    plan_name = Column(String, nullable=False)
    
    billing_cycle = Column(String) # ENUM
    billing_status = Column(String, server_default="active")
    
    subscription_start_date = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    subscription_end_date = Column(DateTime)
    
    razorpay_customer_id = Column(String)
    razorpay_subscription_id = Column(String)
    
    auto_renewal = Column(Boolean, server_default="true")
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

class ABDMIntegration(Base):
    __tablename__ = "abdm_integrations"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID, nullable=False)
    abha_address = Column(String, nullable=False)
    access_token = Column(String)
    refresh_token = Column(String)
    token_expires_at = Column(DateTime)
    consent_artefact_id = Column(String)
    is_active = Column(Boolean, server_default="true")
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
