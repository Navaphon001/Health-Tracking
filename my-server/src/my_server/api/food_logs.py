from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.food_logs import FoodLog

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.food_logs import FoodLog
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
food_logs_db = {}


@router.get("/food_logs", response_model=List[FoodLog])
def get_food_logs(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in food_logs_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/food_logs/{log_id}", response_model=FoodLog)
def get_food_log(log_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    log = food_logs_db.get(log_id)
    if not log or getattr(log, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Food log not found")
    return log


@router.post("/food_logs", response_model=FoodLog)
def create_food_log(log: FoodLog, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if log.id in food_logs_db:
        raise HTTPException(status_code=400, detail="Food log already exists")
    try:
        log.user_id = user_id
    except Exception:
        log = FoodLog(**{**(log.model_dump() if hasattr(log, 'model_dump') else log.__dict__), 'user_id': user_id})
    food_logs_db[log.id] = log
    return log


@router.put("/food_logs/{log_id}", response_model=FoodLog)
def update_food_log(log_id: str, log: FoodLog, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = food_logs_db.get(log_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Food log not found")
    try:
        log.user_id = user_id
    except Exception:
        log = FoodLog(**{**(log.model_dump() if hasattr(log, 'model_dump') else log.__dict__), 'user_id': user_id})
    food_logs_db[log_id] = log
    return log


@router.delete("/food_logs/{log_id}")
def delete_food_log(log_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = food_logs_db.get(log_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Food log not found")
    del food_logs_db[log_id]
    return {"detail": "Food log deleted"}
