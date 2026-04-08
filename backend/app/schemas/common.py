from pydantic import BaseModel
from typing import Any, Optional


class APIResponse(BaseModel):
    status: str = "success"
    data: Optional[Any] = None
    message: Optional[str] = None
