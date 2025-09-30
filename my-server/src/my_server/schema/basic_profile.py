from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime
from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class BasicProfileORM(Base):
    __tablename__ = "basic_profile"
    id = Column("id", String, primary_key=True)
    user_id = Column("user_id", String, index=True)
    full_name = Column("full_name", String)
    date_of_birth = Column("date_of_birth", String)
    gender = Column("gender", String)
    profile_image_url = Column("profile_image_url", String)
    phone_number = Column("phone_number", String)
    address = Column("address", String)
    created_at = Column("created_at", DateTime)
    updated_at = Column("updated_at", DateTime)


class BasicProfile(BaseModel):
    id: str
    # user_id is intentionally omitted from client payloads; server will set it from token
    full_name: Optional[str]
    date_of_birth: Optional[date]
    gender: Optional[str]
    profile_image_url: Optional[str]
    phone_number: Optional[str]
    address: Optional[str]
    created_at: Optional[datetime]
    updated_at: Optional[datetime]
