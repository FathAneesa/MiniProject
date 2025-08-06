from fastapi import FastAPI, HTTPException, Request, Body
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pymongo import MongoClient
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Get Mongo URI from environment
MONGO_URI = os.getenv("MONGO_URI")

# FastAPI app
app = FastAPI()

# CORS for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development. Use specific origins in production.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB setup
client = MongoClient(MONGO_URI)
db = client['wellnessDB']
users_collection = db['users']

# Models
class LoginRequest(BaseModel):
    username: str
    password: str

class RegisterRequest(BaseModel):
    username: str
    password: str

@app.get("/")
def read_root():
    return {"message": "Backend is running"}

@app.post("/register")
def register(register: RegisterRequest = Body(...)):
    if users_collection.find_one({"username": register.username}):
        raise HTTPException(status_code=400, detail="Username already exists")
    users_collection.insert_one({
        "username": register.username,
        "password": register.password
    })
    return {"success": True, "message": "Registration successful"}

@app.post("/login")
def login(login: LoginRequest = Body(...)):
    user = users_collection.find_one({
        "username": login.username,
        "password": login.password
    })
    if user:
        return {"success": True, "message": "Login successful"}
    raise HTTPException(status_code=401, detail="Invalid credentials")

@app.get("/db-status")
def db_status():
    try:
        db.command("ping")
        return {"status": "connected"}
    except Exception as e:
        return {"status": "disconnected", "error": str(e)}

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail}
    )
