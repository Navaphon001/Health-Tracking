from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session
from ..schema.basic_profile import BasicProfile, BasicProfileORM
from ..api import auth as auth_module
from ..schema.auth import Base as AuthBase
from uuid import uuid4
from sqlalchemy import text

SECRET_KEY = auth_module.SECRET_KEY
ALGORITHM = auth_module.ALGORITHM
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

router = APIRouter()


def get_current_user_id(token: str = Depends(oauth2_scheme)) -> str:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("user_id")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token: missing user_id")
        return user_id
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


def _get_allowed_genders(db: Session):
    # Try to read enum values from the database. Fallback to a sensible default set.
    try:
        with db.bind.connect() as conn:
            q = text("SELECT udt_name FROM information_schema.columns WHERE table_name='basic_profile' AND column_name='gender';")
            row = conn.execute(q).fetchone()
            if not row:
                return {"male", "female", "other", None}
            udt = row[0]
            q2 = text("SELECT enumlabel FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = :typ")
            vals = conn.execute(q2, {"typ": udt}).fetchall()
            return {v[0] for v in vals} | {None}
    except Exception:
        return {"male", "female", "other", None}


@router.get("/basic_profile", response_model=List[BasicProfile])
def get_basic_profiles(db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user_id)):
    profiles = db.query(BasicProfileORM).filter(BasicProfileORM.user_id == user_id).all()
    return [BasicProfile(**{k: getattr(p, k) for k in p.__dict__ if not k.startswith('_')}) for p in profiles]


@router.get("/basic_profile/{profile_id}", response_model=BasicProfile)
def get_basic_profile(profile_id: str, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user_id)):
    profile = db.query(BasicProfileORM).filter(BasicProfileORM.id == profile_id, BasicProfileORM.user_id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return BasicProfile(**{k: getattr(profile, k) for k in profile.__dict__ if not k.startswith('_')})


@router.post("/basic_profile", response_model=BasicProfile)
def create_basic_profile(profile: BasicProfile, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user_id)):
    # server assigns user_id from token
    existing = db.query(BasicProfileORM).filter(BasicProfileORM.id == profile.id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Profile already exists")
    # validate gender
    allowed = _get_allowed_genders(db)
    if profile.gender is not None and profile.gender not in allowed:
        raise HTTPException(status_code=400, detail=f"Invalid gender '{profile.gender}'. Allowed: {sorted([x for x in allowed if x is not None])}")
    now = datetime.utcnow() if 'datetime' in globals() else None
    orm = BasicProfileORM(
        id=profile.id,
        user_id=user_id,
        full_name=profile.full_name,
        date_of_birth=str(profile.date_of_birth) if profile.date_of_birth else None,
        gender=profile.gender,
        profile_image_url=profile.profile_image_url,
        phone_number=profile.phone_number,
        address=profile.address,
        created_at=now,
        updated_at=now,
    )
    db.add(orm)
    db.commit()
    db.refresh(orm)
    return BasicProfile(**{k: getattr(orm, k) for k in orm.__dict__ if not k.startswith('_')})


@router.put("/basic_profile/{profile_id}", response_model=BasicProfile)
def update_basic_profile(profile_id: str, profile: BasicProfile, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user_id)):
    orm = db.query(BasicProfileORM).filter(BasicProfileORM.id == profile_id, BasicProfileORM.user_id == user_id).first()
    if not orm:
        raise HTTPException(status_code=404, detail="Profile not found")
    # validate gender
    allowed = _get_allowed_genders(db)
    if profile.gender is not None and profile.gender not in allowed:
        raise HTTPException(status_code=400, detail=f"Invalid gender '{profile.gender}'. Allowed: {sorted([x for x in allowed if x is not None])}")
    # update allowed fields
    orm.full_name = profile.full_name
    orm.date_of_birth = str(profile.date_of_birth) if profile.date_of_birth else None
    orm.gender = profile.gender
    orm.profile_image_url = profile.profile_image_url
    orm.phone_number = profile.phone_number
    orm.address = profile.address
    from datetime import datetime
    orm.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(orm)
    return BasicProfile(**{k: getattr(orm, k) for k in orm.__dict__ if not k.startswith('_')})


@router.delete("/basic_profile/{profile_id}")
def delete_basic_profile(profile_id: str, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user_id)):
    orm = db.query(BasicProfileORM).filter(BasicProfileORM.id == profile_id, BasicProfileORM.user_id == user_id).first()
    if not orm:
        raise HTTPException(status_code=404, detail="Profile not found")
    db.delete(orm)
    db.commit()
    return {"detail": "Profile deleted"}
