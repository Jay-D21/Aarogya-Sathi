from sqlalchemy import Column, String, Integer, Boolean, DateTime, text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class CorporateAccount(Base):
    __tablename__ = "corporate_accounts"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    company_name = Column(String, nullable=False)
    contact_person = Column(String)
    contact_email = Column(String)
    contact_phone = Column(String)
    
    max_employees = Column(Integer, nullable=False)
    is_active = Column(Boolean, server_default="true")
    
    contract_start = Column(DateTime)
    contract_end = Column(DateTime)
    
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
    updated_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

class CorporateEmployeeMapping(Base):
    __tablename__ = "corporate_employee_mapping"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    corporate_id = Column(UUID, nullable=False)
    user_id = Column(UUID, nullable=False)
    
    employee_id = Column(String)
    department = Column(String)
    is_active = Column(Boolean, server_default="true")
    
    linked_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))
