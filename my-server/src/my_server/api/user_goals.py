from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.user_goals import UserGoal

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.user_goals import UserGoal
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
user_goals_db = {}


@router.get("/user_goals", response_model=List[UserGoal])
def get_user_goals(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in user_goals_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/user_goals/{goal_id}", response_model=UserGoal)
def get_user_goal(goal_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    goal = user_goals_db.get(goal_id)
    if not goal or getattr(goal, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Goal not found")
    return goal


@router.post("/user_goals", response_model=UserGoal)
def create_user_goal(goal: UserGoal, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if goal.id in user_goals_db:
        raise HTTPException(status_code=400, detail="Goal already exists")
    try:
        goal.user_id = user_id
    except Exception:
        goal = UserGoal(**{**(goal.model_dump() if hasattr(goal, 'model_dump') else goal.__dict__), 'user_id': user_id})
    user_goals_db[goal.id] = goal
    return goal


@router.put("/user_goals/{goal_id}", response_model=UserGoal)
def update_user_goal(goal_id: str, goal: UserGoal, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = user_goals_db.get(goal_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Goal not found")
    try:
        goal.user_id = user_id
    except Exception:
        goal = UserGoal(**{**(goal.model_dump() if hasattr(goal, 'model_dump') else goal.__dict__), 'user_id': user_id})
    user_goals_db[goal_id] = goal
    return goal


@router.delete("/user_goals/{goal_id}")
def delete_user_goal(goal_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = user_goals_db.get(goal_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Goal not found")
    del user_goals_db[goal_id]
    return {"detail": "Goal deleted"}
