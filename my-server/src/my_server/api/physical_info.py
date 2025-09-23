from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.physical_info import PhysicalInfo

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
physical_info_db = {}

@router.get("/physical_info", response_model=List[PhysicalInfo])
def get_physical_info(current_user: str = Depends(get_current_user)):
    return list(physical_info_db.values())

@router.get("/physical_info/{info_id}", response_model=PhysicalInfo)
def get_physical_info_item(info_id: str, current_user: str = Depends(get_current_user)):
    info = physical_info_db.get(info_id)
    if not info:
        raise HTTPException(status_code=404, detail="Physical info not found")
    return info

@router.post("/physical_info", response_model=PhysicalInfo)
def create_physical_info(info: PhysicalInfo, current_user: str = Depends(get_current_user)):
    if info.id in physical_info_db:
        raise HTTPException(status_code=400, detail="Physical info already exists")
    physical_info_db[info.id] = info
    return info

@router.put("/physical_info/{info_id}", response_model=PhysicalInfo)
def update_physical_info(info_id: str, info: PhysicalInfo, current_user: str = Depends(get_current_user)):
    if info_id not in physical_info_db:
        raise HTTPException(status_code=404, detail="Physical info not found")
    physical_info_db[info_id] = info
    return info

@router.delete("/physical_info/{info_id}")
def delete_physical_info(info_id: str, current_user: str = Depends(get_current_user)):
    if info_id not in physical_info_db:
        raise HTTPException(status_code=404, detail="Physical info not found")
    del physical_info_db[info_id]
    return {"detail": "Physical info deleted"}
