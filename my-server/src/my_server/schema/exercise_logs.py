from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

class ExerciseLog(BaseModel):
    id: str
    user_id: str
    date: date
    activity_type: Optional[str]
    duration: Optional[int]
    calories_burned: Optional[float]
    notes: Optional[str]
    created_at: Optional[datetime]
    updated_at: Optional[datetime]
