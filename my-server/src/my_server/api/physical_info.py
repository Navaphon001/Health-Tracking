from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.physical_info import PhysicalInfo

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.physical_info import PhysicalInfo
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

router = APIRouter(tags=["Physical Info"])
physical_info_db = {}


@router.get("/physical_info", response_model=List[PhysicalInfo])
def get_physical_info(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in physical_info_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/physical_info/{info_id}", response_model=PhysicalInfo)
def get_physical_info_item(info_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    info = physical_info_db.get(info_id)
    if not info or getattr(info, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Physical info not found")
    return info


@router.post("/physical_info", response_model=PhysicalInfo)
def create_physical_info(info: PhysicalInfo, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if info.id in physical_info_db:
        raise HTTPException(status_code=400, detail="Physical info already exists")
    try:
        info.user_id = user_id
    except Exception:
        info = PhysicalInfo(**{**(info.model_dump() if hasattr(info, 'model_dump') else info.__dict__), 'user_id': user_id})
    physical_info_db[info.id] = info
    return info


@router.put("/physical_info/{info_id}", response_model=PhysicalInfo)
def update_physical_info(info_id: str, info: PhysicalInfo, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = physical_info_db.get(info_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Physical info not found")
    try:
        info.user_id = user_id
    except Exception:
        info = PhysicalInfo(**{**(info.model_dump() if hasattr(info, 'model_dump') else info.__dict__), 'user_id': user_id})
    physical_info_db[info_id] = info
    return info


@router.delete("/physical_info/{info_id}")
def delete_physical_info(info_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = physical_info_db.get(info_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Physical info not found")
    del physical_info_db[info_id]
    return {"detail": "Physical info deleted"}
