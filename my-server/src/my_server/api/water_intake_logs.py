from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.water_intake_logs import WaterIntakeLog

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.water_intake_logs import WaterIntakeLog
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

router = APIRouter()
water_intake_logs_db = {}


@router.get("/water_intake_logs", response_model=List[WaterIntakeLog])
def get_water_intake_logs(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in water_intake_logs_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/water_intake_logs/{log_id}", response_model=WaterIntakeLog)
def get_water_intake_log(log_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    log = water_intake_logs_db.get(log_id)
    if not log or getattr(log, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Water intake log not found")
    return log


@router.post("/water_intake_logs", response_model=WaterIntakeLog)
def create_water_intake_log(log: WaterIntakeLog, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if log.id in water_intake_logs_db:
        raise HTTPException(status_code=400, detail="Water intake log already exists")
    try:
        log.user_id = user_id
    except Exception:
        log = WaterIntakeLog(**{**(log.model_dump() if hasattr(log, 'model_dump') else log.__dict__), 'user_id': user_id})
    water_intake_logs_db[log.id] = log
    return log


@router.put("/water_intake_logs/{log_id}", response_model=WaterIntakeLog)
def update_water_intake_log(log_id: str, log: WaterIntakeLog, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = water_intake_logs_db.get(log_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Water intake log not found")
    try:
        log.user_id = user_id
    except Exception:
        log = WaterIntakeLog(**{**(log.model_dump() if hasattr(log, 'model_dump') else log.__dict__), 'user_id': user_id})
    water_intake_logs_db[log_id] = log
    return log


@router.delete("/water_intake_logs/{log_id}")
def delete_water_intake_log(log_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = water_intake_logs_db.get(log_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Water intake log not found")
    del water_intake_logs_db[log_id]
    return {"detail": "Water intake log deleted"}
