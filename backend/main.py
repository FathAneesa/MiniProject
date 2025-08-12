# main.py
import os
from typing import List, Optional
from dotenv import load_dotenv

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId

# ========================
# Load environment variables
# ========================
load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME", "wellnessDB")

if not MONGO_URI:
    raise RuntimeError("❌ MONGO_URI is not set in .env file")

# ========================
# FastAPI app setup
# ========================
app = FastAPI(
    title="Wellness and Performance API",
    description="API for user authentication and data management."
)

# === CORS Middleware ===
origins = [
    "http://localhost",
    "http://localhost:5000",
    "http://127.0.0.1:5000"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ========================
# MongoDB Atlas connection (using motor for async)
# ========================
@app.on_event("startup")
async def startup_db_client():
    """Connects to MongoDB Atlas on app startup."""
    try:
        app.mongodb_client = AsyncIOMotorClient(MONGO_URI)
        app.mongodb = app.mongodb_client[DB_NAME]
        print("✅ Connected to MongoDB Atlas using motor")
    except Exception as e:
        raise RuntimeError(f"❌ MongoDB connection error: {e}")

@app.on_event("shutdown")
async def shutdown_db_client():
    """Closes the MongoDB connection on app shutdown."""
    if hasattr(app, 'mongodb_client'):
        app.mongodb_client.close()
        print("❌ Disconnected from MongoDB Atlas")

# ========================
# Pydantic models
# ========================
# Pydantic model for User registration and login
class User(BaseModel):
    username: str
    password: str
    role: Optional[str] = "student" # Default role for new users

# Pydantic model for the data returned from the database
class UserOut(BaseModel):
    id: str = Field(alias="_id")
    username: str
    role: str

    class Config:
        json_encoders = {ObjectId: str}
        arbitrary_types_allowed = True
        
# ========================
# Routes
# ========================

@app.get("/test-connection", response_description="Test database connection")
async def test_connection():
    """Tests the connection to MongoDB by listing collections."""
    try:
        await app.mongodb.list_collection_names()
        return {"status": "success", "message": "Connected to MongoDB Atlas"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Database connection failed: {str(e)}"
        )

@app.post("/register", response_description="Register a new user", status_code=status.HTTP_201_CREATED)
async def register_user(user: User):
    """Registers a new user."""
    users_collection = app.mongodb["users"]
    
    # Check if username already exists
    if await users_collection.find_one({"username": user.username}):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Username already exists"
        )
    
    user_dict = user.dict()
    
    try:
        result = await users_collection.insert_one(user_dict)
        return {"status": "success", "id": str(result.inserted_id)}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error registering user: {str(e)}"
        )

@app.post("/login", response_description="Login user")
async def login_user(user: User):
    """Authenticates a user and returns a success message on valid credentials."""
    users_collection = app.mongodb["users"]
    
    db_user = await users_collection.find_one({"username": user.username, "password": user.password})

    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password"
        )
        
    return {
        "status": "success",
        "message": "Login successful",
        "role": db_user.get("role", "student") # Return the role from the database
    }

@app.get("/users", response_description="List all users", response_model=List[UserOut])
async def list_users():
    """Fetches and returns a list of all users from the database."""
    users_collection = app.mongodb["users"]
    users = []
    
    try:
        async for u in users_collection.find():
            users.append(UserOut.model_validate(u))
        return users
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching users: {str(e)}"
        )

# === Run the app with Uvicorn ===
# To run this file, save it and use the command:
# uvicorn main:app --host 0.0.0.0 --port 8000 --reload
# Remember to have your .env file with MONGO_URI set.