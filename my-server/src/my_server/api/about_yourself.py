from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.about_yourself import AboutYourself

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
about_yourself_db = {}

@router.get("/about_yourself", response_model=List[AboutYourself])
def get_about_yourself(current_user: str = Depends(get_current_user)):
    return list(about_yourself_db.values())

@router.get("/about_yourself/{about_id}", response_model=AboutYourself)
def get_about_yourself_item(about_id: str, current_user: str = Depends(get_current_user)):
    about = about_yourself_db.get(about_id)
    if not about:
        raise HTTPException(status_code=404, detail="About yourself not found")
    return about

@router.post("/about_yourself", response_model=AboutYourself)
def create_about_yourself(about: AboutYourself, current_user: str = Depends(get_current_user)):
    if about.id in about_yourself_db:
        raise HTTPException(status_code=400, detail="About yourself already exists")
    about_yourself_db[about.id] = about
    return about

@router.put("/about_yourself/{about_id}", response_model=AboutYourself)
def update_about_yourself(about_id: str, about: AboutYourself, current_user: str = Depends(get_current_user)):
    if about_id not in about_yourself_db:
        raise HTTPException(status_code=404, detail="About yourself not found")
    about_yourself_db[about_id] = about
    return about

@router.delete("/about_yourself/{about_id}")
def delete_about_yourself(about_id: str, current_user: str = Depends(get_current_user)):
    if about_id not in about_yourself_db:
        raise HTTPException(status_code=404, detail="About yourself not found")
    del about_yourself_db[about_id]
    return {"detail": "About yourself deleted"}
