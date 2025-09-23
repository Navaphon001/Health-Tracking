from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class PhysicalInfo(BaseModel):
    id: str
    user_id: str
    weight: Optional[float]
    height: Optional[float]
    activity_level: Optional[str]
    created_at: Optional[datetime]
