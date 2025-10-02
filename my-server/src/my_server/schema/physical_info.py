from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from sqlalchemy import Column, String, Float, DateTime
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class PhysicalInfoORM(Base):
    __tablename__ = "physical_info"
    id = Column("id", String, primary_key=True)
    user_id = Column("user_id", String, index=True)
    weight = Column("weight", Float)
    height = Column("height", Float)
    activity_level = Column("activity_level", String)
    created_at = Column("created_at", DateTime)

class PhysicalInfo(BaseModel):
    id: str
    user_id: Optional[str] = None  # Server will set this from token
    weight: Optional[float] = None
    height: Optional[float] = None
    activity_level: Optional[str] = None
    created_at: Optional[datetime] = None
