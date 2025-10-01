from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.exc import IntegrityError
from passlib.context import CryptContext
from jose import jwt  # ✅ ใช้ python-jose ให้ถูกแพ็กเกจ
from datetime import datetime, timedelta
import os

from my_server.schema.auth import User, RegisterRequest, LoginRequest, TokenResponse, Base  # Base อาจใช้ที่อื่น

router = APIRouter(tags=["Authentication"])

# ----------------------------
# Database URL resolver
# ----------------------------
def _get_database_url() -> str:
    url = os.getenv("DATABASE_URL")
    if url:
        return url
    user = os.getenv("DB_USER", "admin")
    password = os.getenv("DB_PASSWORD", "adminpass")
    host = os.getenv("DB_HOST", "postgres")  # service name ใน docker-compose
    port = os.getenv("DB_PORT", "5432")
    name = os.getenv("DB_NAME", "health_db")
    return f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{name}"

DATABASE_URL = _get_database_url()

# โหมดเทสต์/CI: บังคับ SQLite ถ้า TESTING=1 (ช่วยให้ pytest รันได้โดยไม่พึ่ง Postgres)
if os.getenv("TESTING") == "1":
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./ci_test.db")

# ----------------------------
# SQLAlchemy engine/session
# ----------------------------
connect_args = {}
if DATABASE_URL.startswith("sqlite"):
    connect_args = {"check_same_thread": False}
else:
    # psycopg2 connect timeout
    connect_args = {"connect_timeout": 5}

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=300,
    connect_args=connect_args,
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db() -> Session:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ----------------------------
# Auth / JWT
# ----------------------------
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = os.getenv("SECRET_KEY", "CHANGE-ME-IN-PROD")  # ⚠️ เปลี่ยนในโปรดักชัน
ALGORITHM = os.getenv("JWT_ALG", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def _ensure_session(db_like):
    """Normalize dependency-injected DB value to a SQLAlchemy Session.

    Tests sometimes override get_db with callables that return an iterator or generator.
    This helper returns the Session object whether `db_like` is a Session or an iterator
    that yields the Session as its first value.
    """
    # already a Session-like object
    if hasattr(db_like, "query"):
        return db_like

    # generator/iterator case: attempt to retrieve the first yielded value
    try:
        first = next(db_like)
        return first
    except Exception:
        # fallback: return as-is (will likely error downstream)
        return db_like

# ----------------------------
# Routes
# ----------------------------
@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    from uuid import uuid4
    # Normalize injected db to a Session (tests may provide generators/iterators)
    session = _ensure_session(db)
    # ป้องกันซ้ำชั้นแอป
    if session.query(User).filter(User.email == request.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    user = User(
        id=str(uuid4()),
        username=request.username,
        email=request.email,
        password=get_password_hash(request.password),
    )
    session.add(user)
    try:
        session.commit()
    except IntegrityError:
        session.rollback()
        # เผื่อกรณีซ้ำจาก constraint ที่ DB
        raise HTTPException(status_code=400, detail="Email already registered")

    access_token = create_access_token({"sub": request.email, "user_id": user.id})
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/login", response_model=TokenResponse)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    # Authenticate by email + password (OAuth2 form field "username" = email)
    session = _ensure_session(db)
    user = session.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    access_token = create_access_token({"sub": user.email, "user_id": user.id})
    return {"access_token": access_token, "token_type": "bearer"}
