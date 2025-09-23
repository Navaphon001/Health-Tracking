from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.food_logs import FoodLog

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
food_logs_db = {}

@router.get("/food_logs", response_model=List[FoodLog])
def get_food_logs(current_user: str = Depends(get_current_user)):
    return list(food_logs_db.values())

@router.get("/food_logs/{log_id}", response_model=FoodLog)
def get_food_log(log_id: str, current_user: str = Depends(get_current_user)):
    log = food_logs_db.get(log_id)
    if not log:
        raise HTTPException(status_code=404, detail="Food log not found")
    return log

@router.post("/food_logs", response_model=FoodLog)
def create_food_log(log: FoodLog, current_user: str = Depends(get_current_user)):
    if log.id in food_logs_db:
        raise HTTPException(status_code=400, detail="Food log already exists")
    food_logs_db[log.id] = log
    return log

@router.put("/food_logs/{log_id}", response_model=FoodLog)
def update_food_log(log_id: str, log: FoodLog, current_user: str = Depends(get_current_user)):
    if log_id not in food_logs_db:
        raise HTTPException(status_code=404, detail="Food log not found")
    food_logs_db[log_id] = log
    return log

@router.delete("/food_logs/{log_id}")
def delete_food_log(log_id: str, current_user: str = Depends(get_current_user)):
    if log_id not in food_logs_db:
        raise HTTPException(status_code=404, detail="Food log not found")
    del food_logs_db[log_id]
    return {"detail": "Food log deleted"}
