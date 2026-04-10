from sqlalchemy import Column, String, Boolean, DateTime, Numeric, Text, Enum, text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from app.database import Base

plan_enum = Enum("free", "premium", name="subscription_plan_type", create_type=False)
billing_cycle_enum = Enum("monthly", "quarterly", "yearly", name="billing_cycle_type", create_type=False)

class Subscription(Base):
    __tablename__ = "subscriptions"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), nullable=False)

    plan_type = Column(plan_enum, nullable=False)
    plan_name = Column(String)
    plan_description = Column(Text)

    billing_amount_inr = Column(Numeric(10, 2))
    billing_cycle = Column(billing_cycle_enum)
    billing_status = Column(String, server_default="active")

    subscription_start_date = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    subscription_end_date = Column(DateTime)
    next_billing_date = Column(DateTime)
    renewal_date = Column(DateTime)
    auto_renewal = Column(Boolean, server_default="true")
    cancellation_date = Column(DateTime)
    cancellation_reason = Column(Text)

    features_included = Column(JSONB)

    payment_method = Column(String)
    payment_gateway = Column(String)
    payment_id = Column(String)

    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
