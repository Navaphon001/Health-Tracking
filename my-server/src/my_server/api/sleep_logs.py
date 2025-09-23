from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.sleep_logs import SleepLog

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
sleep_logs_db = {}

@router.get("/sleep_logs", response_model=List[SleepLog])
def get_sleep_logs(current_user: str = Depends(get_current_user)):
    return list(sleep_logs_db.values())

@router.get("/sleep_logs/{log_id}", response_model=SleepLog)
def get_sleep_log(log_id: str, current_user: str = Depends(get_current_user)):
    log = sleep_logs_db.get(log_id)
    if not log:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    return log

@router.post("/sleep_logs", response_model=SleepLog)
def create_sleep_log(log: SleepLog, current_user: str = Depends(get_current_user)):
    if log.id in sleep_logs_db:
        raise HTTPException(status_code=400, detail="Sleep log already exists")
    sleep_logs_db[log.id] = log
    return log

@router.put("/sleep_logs/{log_id}", response_model=SleepLog)
def update_sleep_log(log_id: str, log: SleepLog, current_user: str = Depends(get_current_user)):
    if log_id not in sleep_logs_db:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    sleep_logs_db[log_id] = log
    return log

@router.delete("/sleep_logs/{log_id}")
def delete_sleep_log(log_id: str, current_user: str = Depends(get_current_user)):
    if log_id not in sleep_logs_db:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    del sleep_logs_db[log_id]
    return {"detail": "Sleep log deleted"}
