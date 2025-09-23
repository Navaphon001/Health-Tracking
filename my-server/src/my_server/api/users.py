from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.users import User

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

# Mock DB
users_db = {}

@router.get("/users", response_model=List[User])
def get_users(current_user: str = Depends(get_current_user)):
    return list(users_db.values())

@router.get("/users/{user_id}", response_model=User)
def get_user(user_id: str, current_user: str = Depends(get_current_user)):
    user = users_db.get(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/users", response_model=User)
def create_user(user: User, current_user: str = Depends(get_current_user)):
    if user.id in users_db:
        raise HTTPException(status_code=400, detail="User already exists")
    users_db[user.id] = user
    return user

@router.put("/users/{user_id}", response_model=User)
def update_user(user_id: str, user: User, current_user: str = Depends(get_current_user)):
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    users_db[user_id] = user
    return user

@router.delete("/users/{user_id}")
def delete_user(user_id: str, current_user: str = Depends(get_current_user)):
    if user_id not in users_db:
        raise HTTPException(status_code=404, detail="User not found")
    del users_db[user_id]
    return {"detail": "User deleted"}
