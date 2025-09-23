from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.nutrition_database import NutritionDatabase

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
nutrition_db = {}

@router.get("/nutrition_database", response_model=List[NutritionDatabase])
def get_nutrition_database(current_user: str = Depends(get_current_user)):
    return list(nutrition_db.values())

@router.get("/nutrition_database/{food_id}", response_model=NutritionDatabase)
def get_nutrition(food_id: str, current_user: str = Depends(get_current_user)):
    food = nutrition_db.get(food_id)
    if not food:
        raise HTTPException(status_code=404, detail="Food not found")
    return food

@router.post("/nutrition_database", response_model=NutritionDatabase)
def create_nutrition(food: NutritionDatabase, current_user: str = Depends(get_current_user)):
    if food.id in nutrition_db:
        raise HTTPException(status_code=400, detail="Food already exists")
    nutrition_db[food.id] = food
    return food

@router.put("/nutrition_database/{food_id}", response_model=NutritionDatabase)
def update_nutrition(food_id: str, food: NutritionDatabase, current_user: str = Depends(get_current_user)):
    if food_id not in nutrition_db:
        raise HTTPException(status_code=404, detail="Food not found")
    nutrition_db[food_id] = food
    return food

@router.delete("/nutrition_database/{food_id}")
def delete_nutrition(food_id: str, current_user: str = Depends(get_current_user)):
    if food_id not in nutrition_db:
        raise HTTPException(status_code=404, detail="Food not found")
    del nutrition_db[food_id]
    return {"detail": "Food deleted"}
