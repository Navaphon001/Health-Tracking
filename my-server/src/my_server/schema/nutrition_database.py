from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class NutritionDatabase(BaseModel):
    id: str
    food_name: str
    calories: Optional[float]
    protein: Optional[float]
    carbs: Optional[float]
    fat: Optional[float]
    fiber: Optional[float]
    sugar: Optional[float]
    last_updated: Optional[datetime]
