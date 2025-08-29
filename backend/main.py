# /backend/main.py

import os
from typing import List, Optional, Any
from dotenv import load_dotenv

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, Extra
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId

import random
import smtplib
from email.mime.text import MIMEText
from datetime import datetime, timedelta


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

@app.post("/register", response_description="Register a new user", status_code=status.HTTP_201_CREATED)
async def register_user(user: User):
    users_collection = app.mongodb["Users"]
    if await users_collection.find_one({"username": user.username}):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username already exists")
    
    user_dict = user.dict()
    try:
        result = await users_collection.insert_one(user_dict)
        return {"status": "success", "id": str(result.inserted_id)}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error registering user: {str(e)}")

from datetime import datetime

@app.post("/login", response_description="Login user")
async def login_user(user: User):
    """Authenticate a user, log their login time, and return data."""
    users_collection = app.mongodb["Users"]
    db_user = await users_collection.find_one({"username": user.username, "password": user.password})

    if not db_user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid username or password")

    user_role = db_user.get("role", "student")
    response_data = {
        "status": "success",
        "message": "Login successful",
        "role": user_role
    }

    # If the user is a student, fetch their detailed data
    if user_role == "student":
        Students_collection = app.mongodb["Students"]
        student_details = await Students_collection.find_one({"UserID": user.username})
        if student_details:
            student_details["_id"] = str(student_details["_id"])
            response_data["user_data"] = student_details
        else:
            response_data["user_data"] = None

    # ✅ Save login activity for monitoring
    logins_collection = app.mongodb["logins"]
    await logins_collection.insert_one({
        "username": user.username,
        "role": user_role,
        "time": datetime.utcnow()
    })

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
@app.post("/Students/add", status_code=status.HTTP_201_CREATED)
async def add_student(student: dict):
    """Adds a new student with auto-generated username and password, and creates a user login."""

    Students_collection = app.mongodb["Students"]
    users_collection = app.mongodb["Users"]

    # Check duplicate admission number
    if await Students_collection.find_one({"Admission No": student.get("Admission No")}):
        raise HTTPException(status_code=409, detail="Student with this Admission Number already exists.")

    # ✅ Auto-generate username and password
    username = f"STU{random.randint(1000, 9999)}"
    try:
        year, month, day = student.get("dob", "").split("-")
        password = f"{day}{month}{year}"
    except:
        password = "Pass@123"

    # Save in Students collection
    student["UserID"] = username
    student["Password"] = password
    await Students_collection.insert_one(student)

    # Save in Users collection
    user_credentials = {
        "username": username,
        "password": password,
        "role": "student"
    }
    await users_collection.insert_one(user_credentials)

    return {
        "status": "success",
        "message": "Student added successfully",
        "username": username,
        "password": password
    }


@app.get("/Students", response_description="List all Students", response_model=List[dict[str, Any]])
async def list_Students():
    """Fetches and returns a list of all Students."""
    Students_collection = app.mongodb["Students"]
    Students = []
    async for s in Students_collection.find():
        s["_id"] = str(s["_id"]) # Convert ObjectId to string for JSON
        Students.append(s)
    return Students

# === NEW: Academics Route ===
@app.post("/academics/add", response_description="Add academic data for a student", status_code=status.HTTP_201_CREATED)
async def add_academic_data(data: AcademicData):
    """Saves academic data for a specific student."""
    academics_collection = app.mongodb["academics"]
    
    Students_collection = app.mongodb["Students"]
    if not await Students_collection.find_one({"UserID": data.studentId}):
         raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Student with ID {data.studentId} not found.")

    try:
        await academics_collection.insert_one(data.dict())
        return {"status": "success", "message": "Academic data added successfully."}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error saving academic data: {str(e)}")


# === NEW: Get Academic Data for a Student ===
@app.get("/academics/{studentId}", response_description="Get academic data for a student")
async def get_academic_data(studentId: str):
    """Fetches all academic performance entries for a student by ID."""
    academics_collection = app.mongodb["academics"]

    cursor = academics_collection.find({"studentId": studentId})
    results = []
    async for record in cursor:
        record["_id"] = str(record["_id"])  # Convert ObjectId to string
        results.append(record)

    if not results:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No academic data found for student {studentId}"
        )

    return {"status": "success", "data": results}

        # ==========================
# Additional Student Routes
# ==========================

from fastapi import Path

# Get single student by ID
@app.get("/student/{admission_no}")
async def get_student_by_admission_no(admission_no: str):
    Students_collection = app.mongodb["Students"]

    # Strip spaces and match exactly
    student = await Students_collection.find_one({"Admission No": admission_no.strip()})
    
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    student.pop("_id", None)
    return student



# Update student details by Admission No
@app.put("/student/{admission_no}")
async def update_student_by_admission_no(admission_no: str, updated_data: dict):
    Students_collection = app.mongodb["Students"]

    result = await Students_collection.update_one(
        {"Admission No": admission_no.strip()},
        {"$set": updated_data}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Student not found")

    return {"status": "success", "message": "Student updated successfully"}

# Delete student
@app.delete("/student/{admission_no}")
async def delete_student_by_admission_no(admission_no: str):
    Students_collection = app.mongodb["Students"]

    result = await Students_collection.delete_one({"Admission No": admission_no.strip()})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Student not found")

    return {"status": "success", "message": "Student deleted successfully"}


@app.get("/monitor", response_description="Get last 10 logins")
async def monitor():
    """Return the last 10 login activities."""
    logins_collection = app.mongodb["logins"]

    cursor = logins_collection.find().sort("time", -1).limit(10)
    last_logins = []
    async for login in cursor:
        last_logins.append({
            "username": login["username"],
            "role": login["role"],
            "time": login["time"].strftime("%Y-%m-%d %H:%M:%S")
        })

    return {"last_logins": last_logins}
