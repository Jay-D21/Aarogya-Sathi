from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import APIResponse
from app.schemas.chat import ChatMessageRequest, ChatRateRequest
from app.services import chat_service

router = APIRouter()


@router.post("/message", response_model=APIResponse)
async def send_message(
    data: ChatMessageRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Send a health message and get AI-powered response with safety checks."""
    result = await chat_service.process_chat_message(db, current_user, data)
    return APIResponse(data=result.model_dump(mode="json"), message="Response generated")


@router.get("/history", response_model=APIResponse)
async def get_history(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get paginated chat history."""
    result = await chat_service.get_chat_history(db, str(current_user.id), limit, offset)
    return APIResponse(data=result)


@router.post("/{chat_id}/rate", response_model=APIResponse)
async def rate_message(
    chat_id: str,
    data: ChatRateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Rate a chat response (1-5 stars)."""
    result = await chat_service.rate_chat(db, str(current_user.id), chat_id, data.rating, data.feedback)
    if not result:
        return APIResponse(status="error", message="Chat message not found")
    return APIResponse(data=result, message="Rating saved")
