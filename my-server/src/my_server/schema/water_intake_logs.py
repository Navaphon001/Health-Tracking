from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime
from sqlalchemy import Column, String, Date, Integer, DateTime
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class WaterIntakeLogORM(Base):
    __tablename__ = "water_intake_logs"
    id = Column("id", String, primary_key=True)
    user_id = Column("user_id", String, index=True)
    date = Column("date", Date)
    count = Column("count", Integer)
    updated_at = Column("updated_at", DateTime)

class WaterIntakeLog(BaseModel):
    id: str
    user_id: Optional[str] = None  # Server will set this from token
    date: date
    count: Optional[int] = None
    updated_at: Optional[datetime] = None
