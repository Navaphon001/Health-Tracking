from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class Achievement(BaseModel):
    id: str
    user_id: str
    type: Optional[str]
    name: Optional[str]
    description: Optional[str]
    target: Optional[int]
    current: Optional[int]
    achieved: Optional[bool]
    achieved_at: Optional[datetime]
    created_at: Optional[datetime]
