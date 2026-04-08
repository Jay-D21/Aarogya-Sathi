from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime


class ChatMessageRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000)
    language: str = "en"
    include_environmental_context: bool = True


class ChatMessageResponse(BaseModel):
    chat_id: str
    user_message: str
    ai_response: str
    timestamp: datetime
    response_time_ms: int = 0
    tokens_used: int = 0
    environmental_context: Optional[Dict[str, Any]] = None
    safety_flags: Optional[Dict[str, bool]] = None


class ChatHistoryResponse(BaseModel):
    total: int
    limit: int
    offset: int
    messages: List[ChatMessageResponse]


class ChatRateRequest(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    feedback: Optional[str] = None
