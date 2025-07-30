from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class LoginRequest(BaseModel):
    username: str
    password: str

@app.get("/")
def read_root():
    return {"message": "Backend is running"}

@app.post("/login")
def login(request: LoginRequest):
    # TODO: Replace with real authentication logic
    if request.username == "admin" and request.password == "admin":
        return {"success": True, "message": "Login successful"}
    raise HTTPException(status_code=401, detail="Invalid credentials")
