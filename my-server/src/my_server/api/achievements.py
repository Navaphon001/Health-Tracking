from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.achievements import Achievement

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.achievements import Achievement
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
achievements_db = {}


@router.get("/achievements", response_model=List[Achievement])
def get_achievements(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in achievements_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/achievements/{achievement_id}", response_model=Achievement)
def get_achievement(achievement_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    achievement = achievements_db.get(achievement_id)
    if not achievement or getattr(achievement, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Achievement not found")
    return achievement


@router.post("/achievements", response_model=Achievement)
def create_achievement(achievement: Achievement, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if achievement.id in achievements_db:
        raise HTTPException(status_code=400, detail="Achievement already exists")
    try:
        achievement.user_id = user_id
    except Exception:
        achievement = Achievement(**{**(achievement.model_dump() if hasattr(achievement, 'model_dump') else achievement.__dict__), 'user_id': user_id})
    achievements_db[achievement.id] = achievement
    return achievement


@router.put("/achievements/{achievement_id}", response_model=Achievement)
def update_achievement(achievement_id: str, achievement: Achievement, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = achievements_db.get(achievement_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Achievement not found")
    try:
        achievement.user_id = user_id
    except Exception:
        achievement = Achievement(**{**(achievement.model_dump() if hasattr(achievement, 'model_dump') else achievement.__dict__), 'user_id': user_id})
    achievements_db[achievement_id] = achievement
    return achievement


@router.delete("/achievements/{achievement_id}")
def delete_achievement(achievement_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = achievements_db.get(achievement_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Achievement not found")
    del achievements_db[achievement_id]
    return {"detail": "Achievement deleted"}
