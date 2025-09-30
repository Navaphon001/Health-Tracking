from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.sleep_logs import SleepLog

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.sleep_logs import SleepLog
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

router = APIRouter(tags=["Sleep Logs"])
sleep_logs_db = {}


@router.get("/sleep_logs", response_model=List[SleepLog])
def get_sleep_logs(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in sleep_logs_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/sleep_logs/{log_id}", response_model=SleepLog)
def get_sleep_log(log_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    log = sleep_logs_db.get(log_id)
    if not log or getattr(log, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    return log


@router.post("/sleep_logs", response_model=SleepLog)
def create_sleep_log(log: SleepLog, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if log.id in sleep_logs_db:
        raise HTTPException(status_code=400, detail="Sleep log already exists")
    try:
        log.user_id = user_id
    except Exception:
        log = SleepLog(**{**(log.model_dump() if hasattr(log, 'model_dump') else log.__dict__), 'user_id': user_id})
    sleep_logs_db[log.id] = log
    return log


@router.put("/sleep_logs/{log_id}", response_model=SleepLog)
def update_sleep_log(log_id: str, log: SleepLog, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = sleep_logs_db.get(log_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    try:
        log.user_id = user_id
    except Exception:
        log = SleepLog(**{**(log.model_dump() if hasattr(log, 'model_dump') else log.__dict__), 'user_id': user_id})
    sleep_logs_db[log_id] = log
    return log


@router.delete("/sleep_logs/{log_id}")
def delete_sleep_log(log_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = sleep_logs_db.get(log_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Sleep log not found")
    del sleep_logs_db[log_id]
    return {"detail": "Sleep log deleted"}
