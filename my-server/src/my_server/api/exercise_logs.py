from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.exercise_logs import ExerciseLog

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
exercise_logs_db = {}

@router.get("/exercise_logs", response_model=List[ExerciseLog])
def get_exercise_logs(current_user: str = Depends(get_current_user)):
    return list(exercise_logs_db.values())

@router.get("/exercise_logs/{log_id}", response_model=ExerciseLog)
def get_exercise_log(log_id: str, current_user: str = Depends(get_current_user)):
    log = exercise_logs_db.get(log_id)
    if not log:
        raise HTTPException(status_code=404, detail="Exercise log not found")
    return log

@router.post("/exercise_logs", response_model=ExerciseLog)
def create_exercise_log(log: ExerciseLog, current_user: str = Depends(get_current_user)):
    if log.id in exercise_logs_db:
        raise HTTPException(status_code=400, detail="Exercise log already exists")
    exercise_logs_db[log.id] = log
    return log

@router.put("/exercise_logs/{log_id}", response_model=ExerciseLog)
def update_exercise_log(log_id: str, log: ExerciseLog, current_user: str = Depends(get_current_user)):
    if log_id not in exercise_logs_db:
        raise HTTPException(status_code=404, detail="Exercise log not found")
    exercise_logs_db[log_id] = log
    return log

@router.delete("/exercise_logs/{log_id}")
def delete_exercise_log(log_id: str, current_user: str = Depends(get_current_user)):
    if log_id not in exercise_logs_db:
        raise HTTPException(status_code=404, detail="Exercise log not found")
    del exercise_logs_db[log_id]
    return {"detail": "Exercise log deleted"}
