from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

class BasicProfile(BaseModel):
    id: str
    user_id: str
    full_name: Optional[str]
    date_of_birth: Optional[date]
    gender: Optional[str]
    profile_image_url: Optional[str]
    phone_number: Optional[str]
    address: Optional[str]
    created_at: Optional[datetime]
    updated_at: Optional[datetime]
