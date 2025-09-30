from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from datetime import datetime
from sqlalchemy.orm import Session
from ..schema.physical_info import PhysicalInfo, PhysicalInfoORM
from ..api import auth as auth_module

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, auth_module.SECRET_KEY, algorithms=[auth_module.ALGORITHM])
        user_id = payload.get("user_id") or payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

router = APIRouter(tags=["Physical Info"])


@router.get("/physical_info", response_model=List[PhysicalInfo])
def get_physical_info(db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    infos = db.query(PhysicalInfoORM).filter(PhysicalInfoORM.user_id == user_id).all()
    return [PhysicalInfo(**{k: getattr(info, k) for k in info.__dict__ if not k.startswith('_')}) for info in infos]


@router.get("/physical_info/{info_id}", response_model=PhysicalInfo)
def get_physical_info_item(info_id: str, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    info = db.query(PhysicalInfoORM).filter(PhysicalInfoORM.id == info_id, PhysicalInfoORM.user_id == user_id).first()
    if not info:
        raise HTTPException(status_code=404, detail="Physical info not found")
    return PhysicalInfo(**{k: getattr(info, k) for k in info.__dict__ if not k.startswith('_')})


@router.post("/physical_info", response_model=PhysicalInfo)
def create_physical_info(info: PhysicalInfo, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    # Check if already exists
    existing = db.query(PhysicalInfoORM).filter(PhysicalInfoORM.id == info.id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Physical info already exists")
    
    # Create ORM object
    now = datetime.utcnow()
    orm_info = PhysicalInfoORM(
        id=info.id,
        user_id=user_id,
        weight=info.weight,
        height=info.height,
        activity_level=info.activity_level,
        created_at=now,
    )
    
    db.add(orm_info)
    db.commit()
    db.refresh(orm_info)
    
    return PhysicalInfo(**{k: getattr(orm_info, k) for k in orm_info.__dict__ if not k.startswith('_')})


@router.put("/physical_info/{info_id}", response_model=PhysicalInfo)
def update_physical_info(info_id: str, info: PhysicalInfo, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = db.query(PhysicalInfoORM).filter(PhysicalInfoORM.id == info_id, PhysicalInfoORM.user_id == user_id).first()
    if not existing:
        raise HTTPException(status_code=404, detail="Physical info not found")
    
    # Update fields
    existing.weight = info.weight
    existing.height = info.height
    existing.activity_level = info.activity_level
    
    db.commit()
    db.refresh(existing)
    
    return PhysicalInfo(**{k: getattr(existing, k) for k in existing.__dict__ if not k.startswith('_')})


@router.delete("/physical_info/{info_id}")
def delete_physical_info(info_id: str, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = db.query(PhysicalInfoORM).filter(PhysicalInfoORM.id == info_id, PhysicalInfoORM.user_id == user_id).first()
    if not existing:
        raise HTTPException(status_code=404, detail="Physical info not found")
    
    db.delete(existing)
    db.commit()
    
    return {"detail": "Physical info deleted"}
