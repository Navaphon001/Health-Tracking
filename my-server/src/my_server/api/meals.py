from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.meals import Meal

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
meals_db = {}

@router.get("/meals", response_model=List[Meal])
def get_meals(current_user: str = Depends(get_current_user)):
    return list(meals_db.values())

@router.get("/meals/{meal_id}", response_model=Meal)
def get_meal(meal_id: str, current_user: str = Depends(get_current_user)):
    meal = meals_db.get(meal_id)
    if not meal:
        raise HTTPException(status_code=404, detail="Meal not found")
    return meal

@router.post("/meals", response_model=Meal)
def create_meal(meal: Meal, current_user: str = Depends(get_current_user)):
    if meal.id in meals_db:
        raise HTTPException(status_code=400, detail="Meal already exists")
    meals_db[meal.id] = meal
    return meal

@router.put("/meals/{meal_id}", response_model=Meal)
def update_meal(meal_id: str, meal: Meal, current_user: str = Depends(get_current_user)):
    if meal_id not in meals_db:
        raise HTTPException(status_code=404, detail="Meal not found")
    meals_db[meal_id] = meal
    return meal

@router.delete("/meals/{meal_id}")
def delete_meal(meal_id: str, current_user: str = Depends(get_current_user)):
    if meal_id not in meals_db:
        raise HTTPException(status_code=404, detail="Meal not found")
    del meals_db[meal_id]
    return {"detail": "Meal deleted"}
