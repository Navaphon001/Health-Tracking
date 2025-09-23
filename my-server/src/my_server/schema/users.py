from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class User(BaseModel):
    id: str
    username: Optional[str]
    email: Optional[str]
    password: Optional[str]
    createdAt: Optional[datetime]
