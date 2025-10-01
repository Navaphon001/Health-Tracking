from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from my_server.schema.auth import User, RegisterRequest, LoginRequest, TokenResponse
from passlib.context import CryptContext
import jwt
from datetime import datetime, timedelta
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

router = APIRouter(tags=["Authentication"])


# Prefer an explicit DATABASE_URL; otherwise build from DB_* env vars.
def _get_database_url():
	url = os.getenv("DATABASE_URL")
	if url:
		return url
	user = os.getenv("DB_USER", "admin")
	password = os.getenv("DB_PASSWORD", "adminpass")
	# Default to the docker-compose service name so the backend can reach postgres inside compose
	host = os.getenv("DB_HOST", "postgres")
	port = os.getenv("DB_PORT", "5432")
	name = os.getenv("DB_NAME", "health_db")
	return f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{name}"


DATABASE_URL = _get_database_url()

# Create engine with pool_pre_ping to avoid stale connections and a short connect timeout
engine = create_engine(
	DATABASE_URL,
	pool_pre_ping=True,
	connect_args={"connect_timeout": 5},
)

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
