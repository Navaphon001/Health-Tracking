from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class AboutYourselfORM(Base):
    __tablename__ = "about_yourself"
    id = Column("id", String, primary_key=True)
    user_id = Column("user_id", String, index=True)
    health_description = Column("health_description", String)
    health_goal = Column("health_goal", String)
    updated_at = Column("updated_at", DateTime)

class AboutYourself(BaseModel):
    id: str
    user_id: Optional[str] = None  # Server will set this from token
    health_description: Optional[str] = None
    health_goal: Optional[str] = None
    updated_at: Optional[datetime] = None
