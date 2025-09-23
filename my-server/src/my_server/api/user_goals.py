from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.user_goals import UserGoal

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
user_goals_db = {}

@router.get("/user_goals", response_model=List[UserGoal])
def get_user_goals(current_user: str = Depends(get_current_user)):
    return list(user_goals_db.values())

@router.get("/user_goals/{goal_id}", response_model=UserGoal)
def get_user_goal(goal_id: str, current_user: str = Depends(get_current_user)):
    goal = user_goals_db.get(goal_id)
    if not goal:
        raise HTTPException(status_code=404, detail="Goal not found")
    return goal

@router.post("/user_goals", response_model=UserGoal)
def create_user_goal(goal: UserGoal, current_user: str = Depends(get_current_user)):
    if goal.id in user_goals_db:
        raise HTTPException(status_code=400, detail="Goal already exists")
    user_goals_db[goal.id] = goal
    return goal

@router.put("/user_goals/{goal_id}", response_model=UserGoal)
def update_user_goal(goal_id: str, goal: UserGoal, current_user: str = Depends(get_current_user)):
    if goal_id not in user_goals_db:
        raise HTTPException(status_code=404, detail="Goal not found")
    user_goals_db[goal_id] = goal
    return goal

@router.delete("/user_goals/{goal_id}")
def delete_user_goal(goal_id: str, current_user: str = Depends(get_current_user)):
    if goal_id not in user_goals_db:
        raise HTTPException(status_code=404, detail="Goal not found")
    del user_goals_db[goal_id]
    return {"detail": "Goal deleted"}
