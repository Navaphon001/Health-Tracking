from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class AboutYourself(BaseModel):
    id: str
    user_id: str
    health_description: Optional[str]
    health_goal: Optional[str]
    updated_at: Optional[datetime]
