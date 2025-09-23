from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

class WaterIntakeLog(BaseModel):
    id: str
    user_id: str
    date: date
    count: Optional[int]
    updated_at: Optional[datetime]
