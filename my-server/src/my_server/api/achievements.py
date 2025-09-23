from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.achievements import Achievement

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
achievements_db = {}

@router.get("/achievements", response_model=List[Achievement])
def get_achievements(current_user: str = Depends(get_current_user)):
    return list(achievements_db.values())

@router.get("/achievements/{achievement_id}", response_model=Achievement)
def get_achievement(achievement_id: str, current_user: str = Depends(get_current_user)):
    achievement = achievements_db.get(achievement_id)
    if not achievement:
        raise HTTPException(status_code=404, detail="Achievement not found")
    return achievement

@router.post("/achievements", response_model=Achievement)
def create_achievement(achievement: Achievement, current_user: str = Depends(get_current_user)):
    if achievement.id in achievements_db:
        raise HTTPException(status_code=400, detail="Achievement already exists")
    achievements_db[achievement.id] = achievement
    return achievement

@router.put("/achievements/{achievement_id}", response_model=Achievement)
def update_achievement(achievement_id: str, achievement: Achievement, current_user: str = Depends(get_current_user)):
    if achievement_id not in achievements_db:
        raise HTTPException(status_code=404, detail="Achievement not found")
    achievements_db[achievement_id] = achievement
    return achievement

@router.delete("/achievements/{achievement_id}")
def delete_achievement(achievement_id: str, current_user: str = Depends(get_current_user)):
    if achievement_id not in achievements_db:
        raise HTTPException(status_code=404, detail="Achievement not found")
    del achievements_db[achievement_id]
    return {"detail": "Achievement deleted"}
