from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
from my_server.api.auth import router as auth_router
from my_server.api.basic_profile import router as basic_profile_router
from my_server.api.user_goals import router as user_goals_router
from my_server.api.food_logs import router as food_logs_router
from my_server.api.meals import router as meals_router
from my_server.api.achievements import router as achievements_router
from my_server.api.nutrition_database import router as nutrition_database_router
from my_server.api.exercise_logs import router as exercise_logs_router
from my_server.api.sleep_logs import router as sleep_logs_router
from my_server.api.water_intake_logs import router as water_intake_logs_router
from my_server.api.notification_settings import router as notification_settings_router
from my_server.api.physical_info import router as physical_info_router
from my_server.api.about_yourself import router as about_yourself_router

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Hello Server!"}

@app.get("/swagger")
def swagger_redirect():
    return RedirectResponse(url="/docs")

@app.get("/favicon.ico")
def favicon():
    return {"message": "No favicon configured"}

# Include API
app.include_router(auth_router, prefix="/auth")
app.include_router(basic_profile_router)
app.include_router(user_goals_router)
app.include_router(food_logs_router)
app.include_router(meals_router)
app.include_router(achievements_router)
app.include_router(nutrition_database_router)
app.include_router(exercise_logs_router)
app.include_router(sleep_logs_router)
app.include_router(water_intake_logs_router)
app.include_router(notification_settings_router)
app.include_router(physical_info_router)
app.include_router(about_yourself_router)