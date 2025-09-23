from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.basic_profile import BasicProfile

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
basic_profile_db = {}

@router.get("/basic_profile", response_model=List[BasicProfile])
def get_basic_profiles(current_user: str = Depends(get_current_user)):
    return list(basic_profile_db.values())

@router.get("/basic_profile/{profile_id}", response_model=BasicProfile)
def get_basic_profile(profile_id: str, current_user: str = Depends(get_current_user)):
    profile = basic_profile_db.get(profile_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@router.post("/basic_profile", response_model=BasicProfile)
def create_basic_profile(profile: BasicProfile, current_user: str = Depends(get_current_user)):
    if profile.id in basic_profile_db:
        raise HTTPException(status_code=400, detail="Profile already exists")
    basic_profile_db[profile.id] = profile
    return profile

@router.put("/basic_profile/{profile_id}", response_model=BasicProfile)
def update_basic_profile(profile_id: str, profile: BasicProfile, current_user: str = Depends(get_current_user)):
    if profile_id not in basic_profile_db:
        raise HTTPException(status_code=404, detail="Profile not found")
    basic_profile_db[profile_id] = profile
    return profile

@router.delete("/basic_profile/{profile_id}")
def delete_basic_profile(profile_id: str, current_user: str = Depends(get_current_user)):
    if profile_id not in basic_profile_db:
        raise HTTPException(status_code=404, detail="Profile not found")
    del basic_profile_db[profile_id]
    return {"detail": "Profile deleted"}
