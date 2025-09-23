from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.water_intake_logs import WaterIntakeLog

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return username
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

router = APIRouter()
water_intake_logs_db = {}

@router.get("/water_intake_logs", response_model=List[WaterIntakeLog])
def get_water_intake_logs(current_user: str = Depends(get_current_user)):
    return list(water_intake_logs_db.values())

@router.get("/water_intake_logs/{log_id}", response_model=WaterIntakeLog)
def get_water_intake_log(log_id: str, current_user: str = Depends(get_current_user)):
    log = water_intake_logs_db.get(log_id)
    if not log:
        raise HTTPException(status_code=404, detail="Water intake log not found")
    return log

@router.post("/water_intake_logs", response_model=WaterIntakeLog)
def create_water_intake_log(log: WaterIntakeLog, current_user: str = Depends(get_current_user)):
    if log.id in water_intake_logs_db:
        raise HTTPException(status_code=400, detail="Water intake log already exists")
    water_intake_logs_db[log.id] = log
    return log

@router.put("/water_intake_logs/{log_id}", response_model=WaterIntakeLog)
def update_water_intake_log(log_id: str, log: WaterIntakeLog, current_user: str = Depends(get_current_user)):
    if log_id not in water_intake_logs_db:
        raise HTTPException(status_code=404, detail="Water intake log not found")
    water_intake_logs_db[log_id] = log
    return log

@router.delete("/water_intake_logs/{log_id}")
def delete_water_intake_log(log_id: str, current_user: str = Depends(get_current_user)):
    if log_id not in water_intake_logs_db:
        raise HTTPException(status_code=404, detail="Water intake log not found")
    del water_intake_logs_db[log_id]
    return {"detail": "Water intake log deleted"}
