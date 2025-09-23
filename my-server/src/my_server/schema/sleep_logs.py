from pydantic import BaseModel
from typing import Optional
from datetime import date, time, datetime

class SleepLog(BaseModel):
    id: str
    user_id: str
    date: date
    bed_time: Optional[time]
    wake_time: Optional[time]
    sleep_quality: Optional[str]
    notes: Optional[str]
    created_at: Optional[datetime]
    updated_at: Optional[datetime]
