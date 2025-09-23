from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.notification_settings import NotificationSettings

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
notification_settings_db = {}

@router.get("/notification_settings", response_model=List[NotificationSettings])
def get_notification_settings(current_user: str = Depends(get_current_user)):
    return list(notification_settings_db.values())

@router.get("/notification_settings/{setting_id}", response_model=NotificationSettings)
def get_notification_setting(setting_id: str, current_user: str = Depends(get_current_user)):
    setting = notification_settings_db.get(setting_id)
    if not setting:
        raise HTTPException(status_code=404, detail="Notification setting not found")
    return setting

@router.post("/notification_settings", response_model=NotificationSettings)
def create_notification_setting(setting: NotificationSettings, current_user: str = Depends(get_current_user)):
    if setting.id in notification_settings_db:
        raise HTTPException(status_code=400, detail="Notification setting already exists")
    notification_settings_db[setting.id] = setting
    return setting

@router.put("/notification_settings/{setting_id}", response_model=NotificationSettings)
def update_notification_setting(setting_id: str, setting: NotificationSettings, current_user: str = Depends(get_current_user)):
    if setting_id not in notification_settings_db:
        raise HTTPException(status_code=404, detail="Notification setting not found")
    notification_settings_db[setting_id] = setting
    return setting

@router.delete("/notification_settings/{setting_id}")
def delete_notification_setting(setting_id: str, current_user: str = Depends(get_current_user)):
    if setting_id not in notification_settings_db:
        raise HTTPException(status_code=404, detail="Notification setting not found")
    del notification_settings_db[setting_id]
    return {"detail": "Notification setting deleted"}
