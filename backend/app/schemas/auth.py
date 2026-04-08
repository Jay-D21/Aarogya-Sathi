from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import date


class RegisterRequest(BaseModel):
    email: EmailStr
    phone: str = Field(..., min_length=10, max_length=15)
    password: str = Field(..., min_length=8)
    first_name: str = Field(..., min_length=1, max_length=50)
    last_name: Optional[str] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    height_cm: Optional[float] = None
    preferred_language: str = "en"
    preferred_city: Optional[str] = None


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"
    expires_in: int


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class UserResponse(BaseModel):
    id: str
    email: str
    first_name: str
    last_name: Optional[str] = None
    phone: Optional[str] = None
    preferred_language: str = "en"
    preferred_city: Optional[str] = None
    is_verified: bool = False

    class Config:
        from_attributes = True
