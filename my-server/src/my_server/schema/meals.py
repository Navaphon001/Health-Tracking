from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class Meal(BaseModel):
    id: str
    food_log_id: str
    user_id: str
    food_name: Optional[str]
    meal_type: Optional[str]
    image_url: Optional[str]
    created_at: Optional[datetime]
    updated_at: Optional[datetime]
