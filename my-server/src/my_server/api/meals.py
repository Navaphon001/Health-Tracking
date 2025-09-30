from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from ..schema.meals import Meal

SECRET_KEY = "your-secret-key"
from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import List
from ..schema.meals import Meal
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
meals_db = {}


@router.get("/meals", response_model=List[Meal])
def get_meals(db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    return [v for v in meals_db.values() if getattr(v, 'user_id', None) == user_id]


@router.get("/meals/{meal_id}", response_model=Meal)
def get_meal(meal_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    meal = meals_db.get(meal_id)
    if not meal or getattr(meal, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Meal not found")
    return meal


@router.post("/meals", response_model=Meal)
def create_meal(meal: Meal, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    if meal.id in meals_db:
        raise HTTPException(status_code=400, detail="Meal already exists")
    try:
        meal.user_id = user_id
    except Exception:
        meal = Meal(**{**(meal.model_dump() if hasattr(meal, 'model_dump') else meal.__dict__), 'user_id': user_id})
    meals_db[meal.id] = meal
    return meal


@router.put("/meals/{meal_id}", response_model=Meal)
def update_meal(meal_id: str, meal: Meal, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = meals_db.get(meal_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Meal not found")
    try:
        meal.user_id = user_id
    except Exception:
        meal = Meal(**{**(meal.model_dump() if hasattr(meal, 'model_dump') else meal.__dict__), 'user_id': user_id})
    meals_db[meal_id] = meal
    return meal


@router.delete("/meals/{meal_id}")
def delete_meal(meal_id: str, db=Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    existing = meals_db.get(meal_id)
    if not existing or getattr(existing, 'user_id', None) != user_id:
        raise HTTPException(status_code=404, detail="Meal not found")
    del meals_db[meal_id]
    return {"detail": "Meal deleted"}
