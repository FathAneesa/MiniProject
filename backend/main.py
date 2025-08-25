# /backend/main.py

import os
from typing import List, Optional, Any
from dotenv import load_dotenv

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, Extra
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

# === CORS Middleware (FIXED) ===
# Using a wildcard "*" is the easiest way to solve connection issues during development.
# It allows requests from any origin (like your Flutter web app running on a random port).
origins = ["*"]

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
class User(BaseModel):
    username: str
    password: str
    role: Optional[str] = "student"

class UserOut(BaseModel):
    id: str = Field(alias="_id")
    username: str
    role: str

    class Config:
        json_encoders = {ObjectId: str}
        arbitrary_types_allowed = True
        
# NEW: Models for Student and Academic data
class Student(BaseModel, extra=Extra.allow):
    UserID: str
    Password: str

class StudentOut(BaseModel, extra=Extra.allow):
    id: str = Field(alias="_id")

    class Config:
        json_encoders = {ObjectId: str}
        arbitrary_types_allowed = True

class Subject(BaseModel):
    name: str
    mark: str

class AcademicData(BaseModel):
    studentId: str
    subjects: List[Subject]
    studyHours: str
    focusLevel: str
    overallMark: int

# ========================
# Routes
# ========================

@app.get("/test-connection", response_description="Test database connection")
async def test_connection():
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
    users_collection = app.mongodb["users"]
    if await users_collection.find_one({"username": user.username}):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username already exists")
    
    user_dict = user.dict()
    try:
        result = await users_collection.insert_one(user_dict)
        return {"status": "success", "id": str(result.inserted_id)}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error registering user: {str(e)}")

@app.post("/login", response_description="Login user")
async def login_user(user: User):
    """(FIXED) Authenticates a user and returns their data on success."""
    users_collection = app.mongodb["users"]
    db_user = await users_collection.find_one({"username": user.username, "password": user.password})

    if not db_user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid username or password")
    
    user_role = db_user.get("role", "student")
    response_data = {
        "status": "success",
        "message": "Login successful",
        "role": user_role
    }

    # If the user is a student, fetch their detailed data to return to the app
    if user_role == "student":
        students_collection = app.mongodb["students"]
        student_details = await students_collection.find_one({"UserID": user.username})
        if student_details:
            student_details["_id"] = str(student_details["_id"])
            response_data["user_data"] = student_details
        else:
            response_data["user_data"] = None # Student details not found

    return response_data

@app.get("/users", response_description="List all users", response_model=List[UserOut])
async def list_users():
    users_collection = app.mongodb["users"]
    users = []
    try:
        async for u in users_collection.find():
            users.append(UserOut.model_validate(u))
        return users
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error fetching users: {str(e)}")

# === NEW: Student Routes ===
@app.post("/students/add", response_description="Add a new student", status_code=status.HTTP_201_CREATED)
async def add_student(student: Student):
    """Adds a new student and creates a corresponding user login."""
    student_data = student.dict(exclude={"Password"})
    user_credentials = {
        "username": student.UserID,
        "password": student.Password,
        "role": "student"
    }

    students_collection = app.mongodb["students"]
    users_collection = app.mongodb["users"]

    if await students_collection.find_one({"Admission No": student_data.get("Admission No")}):
        raise HTTPException(status_code=409, detail="Student with this Admission Number already exists.")
    if await users_collection.find_one({"username": user_credentials["username"]}):
        raise HTTPException(status_code=409, detail="User with this UserID already exists.")

    try:
        await students_collection.insert_one(student_data)
        await users_collection.insert_one(user_credentials)
        return {"status": "success", "message": "Student added and user created successfully."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

@app.get("/students", response_description="List all students", response_model=List[dict[str, Any]])
async def list_students():
    """Fetches and returns a list of all students."""
    students_collection = app.mongodb["students"]
    students = []
    async for s in students_collection.find():
        s["_id"] = str(s["_id"]) # Convert ObjectId to string for JSON
        students.append(s)
    return students

# === NEW: Academics Route ===
@app.post("/academics/add", response_description="Add academic data for a student", status_code=status.HTTP_201_CREATED)
async def add_academic_data(data: AcademicData):
    """Saves academic data for a specific student."""
    academics_collection = app.mongodb["academics"]
    
    students_collection = app.mongodb["students"]
    if not await students_collection.find_one({"UserID": data.studentId}):
         raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Student with ID {data.studentId} not found.")

    try:
        await academics_collection.insert_one(data.dict())
        return {"status": "success", "message": "Academic data added successfully."}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error saving academic data: {str(e)}")