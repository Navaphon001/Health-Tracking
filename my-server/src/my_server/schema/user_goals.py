from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

class UserGoal(BaseModel):
    id: str
    user_id: str
    goal_type: Optional[str]
    goal_value: Optional[float]
    goal_current: Optional[float]
    start_date: Optional[date]
    end_date: Optional[date]
    is_active: Optional[bool]
    created_at: Optional[datetime]
    updated_at: Optional[datetime]
