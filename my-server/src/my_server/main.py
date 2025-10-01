from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import time
import pathlib
import uvicorn
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError
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


# --- Database startup helper: wait for DB and apply init.sql if needed ---
def _get_database_url():
    # prefer explicit DATABASE_URL, otherwise use docker-friendly defaults
    url = os.getenv("DATABASE_URL")
    if url:
        return url
    user = os.getenv("DB_USER", "wellness_user")
    password = os.getenv("DB_PASSWORD", "wellness_password")
    host = os.getenv("DB_HOST", "postgres")
    port = os.getenv("DB_PORT", "5432")
    name = os.getenv("DB_NAME", "wellness_tracker_db")
    return f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{name}"


def wait_for_db_and_init(retries: int = 15, delay: int = 2):
    db_url = _get_database_url()
    engine = None
    for i in range(retries):
        try:
            engine = create_engine(db_url, pool_pre_ping=True)
            with engine.connect() as conn:
                # quick sanity query
                conn.execute(text("SELECT 1"))
            break
        except OperationalError as exc:
            print(f"DB not ready (attempt {i+1}/{retries}): {exc}")
            time.sleep(delay)
    else:
        raise RuntimeError("Database not available after retries")

    # check for users table; if missing, apply init.sql found in repo under my-server/src/my_server/db/init.sql
    try:
        with engine.connect() as conn:
            res = conn.execute(text("SELECT to_regclass('public.users')"))
            row = res.fetchone()
            exists = bool(row and row[0])
            if not exists:
                print("users table not found — applying init.sql")
                # load SQL file
                sql_path = pathlib.Path(__file__).resolve().parents[1] / "db" / "init.sql"
                if sql_path.exists():
                    sql_text = sql_path.read_text(encoding="utf-8")
                    # Execute the SQL blob; Postgres accepts multiple commands
                    with engine.begin() as trans_conn:
                        trans_conn.execute(text(sql_text))
                    print("Applied init.sql")
                else:
                    print(f"init.sql not found at {sql_path}; cannot initialize schema")
            else:
                print("users table exists; no init needed")
    except Exception as exc:
        print(f"Error during DB init check/apply: {exc}")


@app.on_event("startup")
def startup_db():
    try:
        wait_for_db_and_init()
    except Exception as exc:
        # if startup DB init fails, raise to avoid running with broken DB
        print(f"Startup DB init failed: {exc}")
        raise


if __name__ == "__main__":
    # Allow running the app directly with: python -m my_server.main (when PYTHONPATH includes src)
    # or: set PORT and run python -m my_server.main
    host = os.environ.get("HOST", "0.0.0.0")
    port = int(os.environ.get("PORT", 8000))
    # Use reload only in development
    reload_flag = os.environ.get("RELOAD", "true").lower() in ("1", "true", "yes")
    uvicorn.run("my_server.main:app", host=host, port=port, reload=reload_flag)