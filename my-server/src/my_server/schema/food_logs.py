from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

class FoodLog(BaseModel):
    id: str
    user_id: str
    date: date
    last_modified: Optional[datetime]
    meal_count: Optional[int]
