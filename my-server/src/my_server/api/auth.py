from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from my_server.schema.auth import User, RegisterRequest, LoginRequest, TokenResponse
from passlib.context import CryptContext
import jwt
from datetime import datetime, timedelta
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

router = APIRouter(tags=["Authentication"])

# DB config from docker-compose
DB_USER = "admin"
DB_PASSWORD = "adminpass"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "health_db"
DATABASE_URL = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
from my_server.schema.auth import Base

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = "your-secret-key"  # Change this in production
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60


def verify_password(plain_password, hashed_password):
	return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
	return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta = None):
	to_encode = data.copy()
	expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
	to_encode.update({"exp": expire})
	encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
	return encoded_jwt

def get_db():
	db = SessionLocal()
	try:
		yield db
	finally:
		db.close()

@router.post("/register", response_model=TokenResponse)
def register(request: RegisterRequest, db=Depends(get_db)):
	from uuid import uuid4
	# Allow duplicate usernames; enforce unique email only
	email_exist = db.query(User).filter(User.email == request.email).first()
	if email_exist:
		raise HTTPException(status_code=400, detail="Email already registered")
	hashed_password = get_password_hash(request.password)
	user = User(id=str(uuid4()), username=request.username, email=request.email, password=hashed_password)
	db.add(user)
	db.commit()
	# include user id in token
	access_token = create_access_token({"sub": request.email, "user_id": user.id})
	return {"access_token": access_token, "token_type": "bearer"}

@router.post("/login", response_model=TokenResponse)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db=Depends(get_db)):
	# Authenticate by email + password
	user = db.query(User).filter(User.email == form_data.username).first()
	if not user or not verify_password(form_data.password, user.password):
		raise HTTPException(status_code=401, detail="Incorrect email or password")
	access_token = create_access_token({"sub": user.email, "user_id": user.id})
	return {"access_token": access_token, "token_type": "bearer"}
