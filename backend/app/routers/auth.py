from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import APIResponse
from app.schemas.auth import (
    RegisterRequest,
    LoginRequest,
    RefreshTokenRequest,
    UserResponse,
)
from app.services import auth_service

router = APIRouter()


@router.post("/register", response_model=APIResponse)
async def register(data: RegisterRequest, db: AsyncSession = Depends(get_db)):
    """Register a new user account."""
    user = await auth_service.register_user(db, data)
    return APIResponse(
        data=UserResponse(
            id=str(user.id),
            email=user.email,
            first_name=user.first_name,
            last_name=user.last_name,
            phone=user.phone,
            preferred_language=user.preferred_language,
            preferred_city=user.preferred_city,
        ),
        message="Registration successful",
    )


@router.post("/login", response_model=APIResponse)
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    """Authenticate and receive JWT tokens."""
    tokens = await auth_service.login_user(db, data)
    return APIResponse(data=tokens.model_dump(), message="Login successful")


@router.post("/refresh-token", response_model=APIResponse)
async def refresh_token(data: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    """Get a new access token using a refresh token."""
    result = await auth_service.refresh_access_token(db, data.refresh_token)
    return APIResponse(data=result, message="Token refreshed")


@router.post("/logout", response_model=APIResponse)
async def logout(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Logout and invalidate all sessions."""
    await auth_service.logout_user(db, str(current_user.id))
    return APIResponse(message="Logged out successfully")


@router.get("/me", response_model=APIResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    """Get current authenticated user profile."""
    return APIResponse(
        data=UserResponse(
            id=str(current_user.id),
            email=current_user.email,
            first_name=current_user.first_name,
            last_name=current_user.last_name,
            phone=current_user.phone,
            preferred_language=current_user.preferred_language or "en",
            preferred_city=current_user.preferred_city,
            is_verified=current_user.is_verified or False,
        ),
    )
