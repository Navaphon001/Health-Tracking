from fastapi import FastAPI
from my_server.api.auth import router as auth_router
from my_server.api.protected import router as protected_router

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello Server!"}

# Include Auth API
app.include_router(auth_router, prefix="/auth")
# Include Protected API
app.include_router(protected_router)