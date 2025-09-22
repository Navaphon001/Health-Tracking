from pydantic import BaseModel, EmailStr
from datetime import datetime
from sqlalchemy import Column, String, DateTime
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column("id", String, primary_key=True)
    username = Column("username", String, unique=True, index=True)
    email = Column("email", String, unique=True, index=True)
    password = Column("password", String)  # ระบุชื่อ column ตรงนี้
    createdAt = Column("createdAt", DateTime, default=datetime.utcnow)

class RegisterRequest(BaseModel):
    username: str
    email: EmailStr
    password: str

class LoginRequest(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
