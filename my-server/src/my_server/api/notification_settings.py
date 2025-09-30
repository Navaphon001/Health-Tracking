from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.notification_settings import NotificationSettings

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.notification_settings import NotificationSettings
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

router = APIRouter(tags=["Notification Settings"])
notification_settings_db = {}


@router.get("/notification_settings", response_model=List[NotificationSettings])
def get_notification_settings(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in notification_settings_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/notification_settings/{setting_id}", response_model=NotificationSettings)
def get_notification_setting(setting_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    setting = notification_settings_db.get(setting_id)
    if not setting or getattr(setting, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Notification setting not found")
    return setting


@router.post("/notification_settings", response_model=NotificationSettings)
def create_notification_setting(setting: NotificationSettings, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if setting.id in notification_settings_db:
        raise HTTPException(status_code=400, detail="Notification setting already exists")
    try:
        setting.user_id = user_id
    except Exception:
        setting = NotificationSettings(**{**(setting.model_dump() if hasattr(setting, 'model_dump') else setting.__dict__), 'user_id': user_id})
    notification_settings_db[setting.id] = setting
    return setting


@router.put("/notification_settings/{setting_id}", response_model=NotificationSettings)
def update_notification_setting(setting_id: str, setting: NotificationSettings, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = notification_settings_db.get(setting_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Notification setting not found")
    try:
        setting.user_id = user_id
    except Exception:
        setting = NotificationSettings(**{**(setting.model_dump() if hasattr(setting, 'model_dump') else setting.__dict__), 'user_id': user_id})
    notification_settings_db[setting_id] = setting
    return setting


@router.delete("/notification_settings/{setting_id}")
def delete_notification_setting(setting_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = notification_settings_db.get(setting_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Notification setting not found")
    del notification_settings_db[setting_id]
    return {"detail": "Notification setting deleted"}
