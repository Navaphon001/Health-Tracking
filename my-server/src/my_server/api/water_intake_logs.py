from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from datetime import datetime
from sqlalchemy.orm import Session
from ..schema.water_intake_logs import WaterIntakeLog, WaterIntakeLogORM
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

router = APIRouter(tags=["Water Intake Logs"])


@router.get("/water_intake_logs", response_model=List[WaterIntakeLog])
def get_water_intake_logs(db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    logs = db.query(WaterIntakeLogORM).filter(WaterIntakeLogORM.user_id == user_id).all()
    return [WaterIntakeLog(
        id=log.id,
        user_id=log.user_id,
        date=log.date,
        count=log.count,
        updated_at=log.updated_at
    ) for log in logs]


@router.get("/water_intake_logs/{log_id}", response_model=WaterIntakeLog)
def get_water_intake_log(log_id: str, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    log = db.query(WaterIntakeLogORM).filter(
        WaterIntakeLogORM.id == log_id,
        WaterIntakeLogORM.user_id == user_id
    ).first()
    if not log:
        raise HTTPException(status_code=404, detail="Water intake log not found")
    return WaterIntakeLog(
        id=log.id,
        user_id=log.user_id,
        date=log.date,
        count=log.count,
        updated_at=log.updated_at
    )


@router.post("/water_intake_logs", response_model=WaterIntakeLog)
def create_water_intake_log(log: WaterIntakeLog, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    # Check if record already exists
    existing = db.query(WaterIntakeLogORM).filter(WaterIntakeLogORM.id == log.id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Water intake log already exists")
    
    # Create new database record
    db_record = WaterIntakeLogORM(
        id=log.id,
        user_id=user_id,
        date=log.date,
        count=log.count,
        updated_at=datetime.now()
    )
    
    db.add(db_record)
    db.commit()
    db.refresh(db_record)
    
    return WaterIntakeLog(
        id=db_record.id,
        user_id=db_record.user_id,
        date=db_record.date,
        count=db_record.count,
        updated_at=db_record.updated_at
    )


@router.put("/water_intake_logs/{log_id}", response_model=WaterIntakeLog)
def update_water_intake_log(log_id: str, log: WaterIntakeLog, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    # Find existing record
    db_record = db.query(WaterIntakeLogORM).filter(
        WaterIntakeLogORM.id == log_id,
        WaterIntakeLogORM.user_id == user_id
    ).first()
    
    if not db_record:
        raise HTTPException(status_code=404, detail="Water intake log not found")
    
    # Update fields
    db_record.date = log.date
    db_record.count = log.count
    db_record.updated_at = datetime.now()
    
    db.commit()
    db.refresh(db_record)
    
    return WaterIntakeLog(
        id=db_record.id,
        user_id=db_record.user_id,
        date=db_record.date,
        count=db_record.count,
        updated_at=db_record.updated_at
    )


@router.delete("/water_intake_logs/{log_id}")
def delete_water_intake_log(log_id: str, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    # Find existing record
    db_record = db.query(WaterIntakeLogORM).filter(
        WaterIntakeLogORM.id == log_id,
        WaterIntakeLogORM.user_id == user_id
    ).first()
    
    if not db_record:
        raise HTTPException(status_code=404, detail="Water intake log not found")
    
    db.delete(db_record)
    db.commit()
    
    return {"detail": "Water intake log deleted"}
