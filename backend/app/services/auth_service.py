from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import HTTPException, status
from app.models.user import User
from app.models.preferences import UserPreference
from app.models.subscription import Subscription
from app.models.auth_session import AuthSession
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse
from app.utils.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    verify_token,
)
from app.config import settings


async def register_user(db: AsyncSession, data: RegisterRequest) -> User:
    """Register a new user, create default preferences and free subscription."""
    # Check if email already exists
    result = await db.execute(select(User).where(User.email == data.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    # Check if phone already exists
    result = await db.execute(select(User).where(User.phone == data.phone))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number already registered",
        )

    # Create user
    user = User(
        email=data.email,
        phone=data.phone,
        password_hash=hash_password(data.password),
        first_name=data.first_name,
        last_name=data.last_name,
        date_of_birth=data.date_of_birth,
        gender=data.gender,
        height_cm=data.height_cm,
        preferred_language=data.preferred_language,
        preferred_city=data.preferred_city,
    )
    db.add(user)
    await db.flush()  # Get the auto-generated user.id

    # Create default preferences
    preferences = UserPreference(user_id=user.id)
    db.add(preferences)

    # Create free subscription
    subscription = Subscription(
        user_id=user.id,
        plan_type="free",
        plan_name="Aarogya Sathi Basic",
    )
    db.add(subscription)

    await db.commit()
    await db.refresh(user)
    return user


async def login_user(db: AsyncSession, data: LoginRequest) -> TokenResponse:
    """Authenticate user and return JWT tokens."""
    result = await db.execute(select(User).where(User.email == data.email))
    user = result.scalar_one_or_none()

    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is deactivated",
        )

    # Create tokens
    token_data = {"sub": str(user.id)}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    # Record auth session
    session = AuthSession(
        user_id=user.id,
        access_token=access_token,
        refresh_token=refresh_token,
        expires_at=datetime.utcnow() + timedelta(minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES),
        refresh_token_expires_at=datetime.utcnow() + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS),
    )
    db.add(session)

    # Update last login
    user.last_login_at = datetime.utcnow()
    await db.commit()

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


async def refresh_access_token(db: AsyncSession, refresh_token: str) -> dict:
    """Verify refresh token and issue a new access token."""
    payload = verify_token(refresh_token)

    if payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token type. Refresh token required.",
        )

    # Check if refresh token is still active in the database
    result = await db.execute(
        select(AuthSession).where(
            AuthSession.refresh_token == refresh_token,
            AuthSession.is_active == True,
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token has been revoked",
        )

    # Check if refresh token has expired
    if session.refresh_token_expires_at and datetime.utcnow() > session.refresh_token_expires_at:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token has expired",
        )

    new_access_token = create_access_token({"sub": payload["sub"]})
    return {
        "access_token": new_access_token,
        "token_type": "Bearer",
        "expires_in": settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    }


async def logout_user(db: AsyncSession, user_id: str) -> None:
    """Deactivate all active sessions for the user."""
    result = await db.execute(
        select(AuthSession).where(
            AuthSession.user_id == user_id,
            AuthSession.is_active == True,
        )
    )
    sessions = result.scalars().all()
    for session in sessions:
        session.is_active = False
        session.logged_out_at = datetime.utcnow()

    await db.commit()
