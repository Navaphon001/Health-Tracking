from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.about_yourself import AboutYourself

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.about_yourself import AboutYourself
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

router = APIRouter(tags=["About Yourself"])
about_yourself_db = {}


@router.get("/about_yourself", response_model=List[AboutYourself])
def get_about_yourself(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in about_yourself_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/about_yourself/{about_id}", response_model=AboutYourself)
def get_about_yourself_item(about_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    about = about_yourself_db.get(about_id)
    if not about or getattr(about, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="About yourself not found")
    return about


@router.post("/about_yourself", response_model=AboutYourself)
def create_about_yourself(about: AboutYourself, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if about.id in about_yourself_db:
        raise HTTPException(status_code=400, detail="About yourself already exists")
    try:
        about.user_id = user_id
    except Exception:
        about = AboutYourself(**{**(about.model_dump() if hasattr(about, 'model_dump') else about.__dict__), 'user_id': user_id})
    about_yourself_db[about.id] = about
    return about


@router.put("/about_yourself/{about_id}", response_model=AboutYourself)
def update_about_yourself(about_id: str, about: AboutYourself, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = about_yourself_db.get(about_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="About yourself not found")
    try:
        about.user_id = user_id
    except Exception:
        about = AboutYourself(**{**(about.model_dump() if hasattr(about, 'model_dump') else about.__dict__), 'user_id': user_id})
    about_yourself_db[about_id] = about
    return about


@router.delete("/about_yourself/{about_id}")
def delete_about_yourself(about_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = about_yourself_db.get(about_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="About yourself not found")
    del about_yourself_db[about_id]
    return {"detail": "About yourself deleted"}
