from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.nutrition_database import NutritionDatabase

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.nutrition_database import NutritionDatabase
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
nutrition_db = {}


@router.get("/nutrition_database", response_model=List[NutritionDatabase])
def get_nutrition_database(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in nutrition_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/nutrition_database/{food_id}", response_model=NutritionDatabase)
def get_nutrition(food_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    food = nutrition_db.get(food_id)
    if not food or getattr(food, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Food not found")
    return food


@router.post("/nutrition_database", response_model=NutritionDatabase)
def create_nutrition(food: NutritionDatabase, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if food.id in nutrition_db:
        raise HTTPException(status_code=400, detail="Food already exists")
    try:
        food.user_id = user_id
    except Exception:
        food = NutritionDatabase(**{**(food.model_dump() if hasattr(food, 'model_dump') else food.__dict__), 'user_id': user_id})
    nutrition_db[food.id] = food
    return food


@router.put("/nutrition_database/{food_id}", response_model=NutritionDatabase)
def update_nutrition(food_id: str, food: NutritionDatabase, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = nutrition_db.get(food_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Food not found")
    try:
        food.user_id = user_id
    except Exception:
        food = NutritionDatabase(**{**(food.model_dump() if hasattr(food, 'model_dump') else food.__dict__), 'user_id': user_id})
    nutrition_db[food_id] = food
    return food


@router.delete("/nutrition_database/{food_id}")
def delete_nutrition(food_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = nutrition_db.get(food_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Food not found")
    del nutrition_db[food_id]
    return {"detail": "Food deleted"}
