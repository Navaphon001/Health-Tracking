from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class NotificationSettings(BaseModel):
    id: str
    user_id: str
    water_reminder_enabled: Optional[bool]
    exercise_reminder_enabled: Optional[bool]
    meal_logging_enabled: Optional[bool]
    sleep_reminder_enabled: Optional[bool]
    updated_at: Optional[datetime]
