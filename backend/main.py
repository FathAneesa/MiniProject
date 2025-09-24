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
from datetime import datetime, timedelta, timezone

from bson import ObjectId, json_util
import json
from fastapi.responses import JSONResponse


# ========================
# Load environment variables
# ========================
load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME", "wellnessDB")

# Email configuration
SMTP_SERVER = os.getenv("EMAIL_HOST", "smtp.gmail.com")
SMTP_PORT = int(os.getenv("EMAIL_PORT", "587"))
EMAIL_ADDRESS = os.getenv("EMAIL_USER")
EMAIL_PASSWORD = os.getenv("EMAIL_PASS")

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
    mark: int

class AcademicData(BaseModel):
    studentId: str
    subjects: List[Subject]
    studyHours: str
    focusLevel: str
    overallMark: int

# OTP Models
class EmailCheckRequest(BaseModel):
    email: str

class OTPRequest(BaseModel):
    email: str

class OTPVerifyRequest(BaseModel):
    email: str
    otp: str
    token: str

class PasswordResetRequest(BaseModel):
    email: str
    newPassword: str
    token: str

# ========================
# Email and OTP utility functions
# ========================

async def send_email_otp(to_email: str, otp: str) -> bool:
    """Send OTP via email using SMTP"""
    if not EMAIL_ADDRESS or not EMAIL_PASSWORD:
        print("❌ Email credentials not configured")
        return False
    
    try:
        # Create message
        subject = "Password Reset OTP - AI Wellness System"
        body = f"""
        Dear User,
        
        Your One-Time Password (OTP) for password reset is: {otp}
        
        This OTP is valid for 10 minutes. Please do not share this code with anyone.
        
        If you didn't request this, please ignore this email.
        
        Best regards,
        AI Wellness System Team
        """
        
        msg = MIMEText(body)
        msg['Subject'] = subject
        msg['From'] = EMAIL_ADDRESS
        msg['To'] = to_email
        
        # Send email
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.send_message(msg)
        
        print(f"✅ OTP email sent successfully to {to_email}")
        return True
    except Exception as e:
        print(f"❌ Failed to send email: {str(e)}")
        return False

def generate_otp() -> str:
    """Generate a 6-digit OTP"""
    return str(random.randint(100000, 999999))

def generate_token() -> str:
    """Generate a random token for verification"""
    return f"token_{random.randint(100000, 999999)}_{int(datetime.utcnow().timestamp())}"

# ========================
# OTP Routes
# ========================

@app.post("/auth/check-email", response_description="Check if email exists")
async def check_email_exists(request: EmailCheckRequest):
    """Check if email exists in the database"""
    students_collection = app.mongodb["Students"]
    
    # Check if email exists in students collection
    student = await students_collection.find_one({
        "Email": {"$regex": f"^{request.email}$", "$options": "i"}
    })
    
    return {
        "exists": student is not None,
        "message": "Email found" if student else "Email not found"
    }

@app.post("/auth/send-otp", response_description="Send OTP to email")
async def send_otp_to_email(request: OTPRequest):
    """Generate and send OTP to user's email"""
    students_collection = app.mongodb["Students"]
    otp_collection = app.mongodb["otp_tokens"]
    
    # Verify email exists
    student = await students_collection.find_one({
        "Email": {"$regex": f"^{request.email}$", "$options": "i"}
    })
    
    if not student:
        raise HTTPException(status_code=404, detail="Email not found")
    
    # Generate OTP and token
    otp = generate_otp()
    token = generate_token()
    
    # Store OTP in database with expiration
    expiry_time = datetime.utcnow() + timedelta(minutes=10)
    
    await otp_collection.update_one(
        {"email": request.email},
        {
            "$set": {
                "email": request.email,
                "otp": otp,
                "token": token,
                "created_at": datetime.utcnow(),
                "expires_at": expiry_time,
                "verified": False
            }
        },
        upsert=True
    )
    
    # Send email
    email_sent = await send_email_otp(request.email, otp)
    
    if not email_sent:
        # If real email fails, provide debug info but still return success for development
        print(f"📧 DEBUG: OTP for {request.email} is {otp}")
        return {
            "success": True,
            "message": "OTP generated (email service unavailable, check console for OTP)",
            "token": token,
            "debug_otp": otp  # Remove this in production
        }
    
    return {
        "success": True,
        "message": "OTP sent successfully to your email",
        "token": token
    }

@app.post("/auth/verify-otp", response_description="Verify OTP")
async def verify_otp(request: OTPVerifyRequest):
    """Verify the OTP entered by user"""
    otp_collection = app.mongodb["otp_tokens"]
    
    # Find OTP record
    otp_record = await otp_collection.find_one({
        "email": request.email,
        "token": request.token
    })
    
    if not otp_record:
        raise HTTPException(status_code=400, detail="Invalid token or email")
    
    # Check if OTP is expired
    if datetime.utcnow() > otp_record["expires_at"]:
        raise HTTPException(status_code=400, detail="OTP has expired")
    
    # Check if OTP matches
    if otp_record["otp"] != request.otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    
    # Mark as verified and generate reset token
    reset_token = generate_token()
    
    await otp_collection.update_one(
        {"email": request.email, "token": request.token},
        {
            "$set": {
                "verified": True,
                "reset_token": reset_token,
                "verified_at": datetime.utcnow()
            }
        }
    )
    
    return {
        "valid": True,
        "message": "OTP verified successfully",
        "resetToken": reset_token
    }

@app.post("/auth/reset-password", response_description="Reset password")
async def reset_password(request: PasswordResetRequest):
    """Reset user password after OTP verification"""
    otp_collection = app.mongodb["otp_tokens"]
    students_collection = app.mongodb["Students"]
    users_collection = app.mongodb["Users"]
    
    # Verify reset token
    otp_record = await otp_collection.find_one({
        "email": request.email,
        "reset_token": request.token,
        "verified": True
    })
    
    if not otp_record:
        raise HTTPException(status_code=400, detail="Invalid reset token")
    
    # Check if token is still valid (within 30 minutes of verification)
    if datetime.utcnow() > otp_record["verified_at"] + timedelta(minutes=30):
        raise HTTPException(status_code=400, detail="Reset token has expired")
    
    # Find student by email
    student = await students_collection.find_one({
        "Email": {"$regex": f"^{request.email}$", "$options": "i"}
    })
    
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    # Update password in both collections
    user_id = student.get("UserID")
    
    # Update in Students collection
    await students_collection.update_one(
        {"Email": {"$regex": f"^{request.email}$", "$options": "i"}},
        {"$set": {"Password": request.newPassword}}
    )
    
    # Update in Users collection
    await users_collection.update_one(
        {"username": user_id},
        {"$set": {"password": request.newPassword}}
    )
    
    # Clean up OTP record
    await otp_collection.delete_one({"email": request.email})
    
    return {
        "success": True,
        "message": "Password reset successfully"
    }

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

    # ✅ Save login activity for monitoring with timezone-aware datetime
    logins_collection = app.mongodb["logins"]
    await logins_collection.insert_one({
        "username": user.username,
        "role": user_role,
        "time": datetime.utcnow()
    })

    return response_data


@app.get("/users", response_description="List all users", response_model=List[UserOut])
async def list_users():
    users_collection = app.mongodb["Users"]  # Fixed collection name
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

    Students_collection = app.mongodb["Students"]  # Fixed collection name
    users_collection = app.mongodb["Users"]        # Fixed collection name

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

@app.get("/students")
async def list_students():
    students_collection = app.mongodb["Students"]  # Fixed collection name

    # Fetch all documents
    students_cursor = students_collection.find()
    students = []
    async for s in students_cursor:
        students.append(s)

    # Serialize using bson.json_util
    students_json = json.loads(json_util.dumps(students))

    # Return as FastAPI JSONResponse
    return JSONResponse(content=students_json)



# === NEW: Academics Route ===
@app.post("/academics/add", response_description="Add academic data for a student", status_code=status.HTTP_201_CREATED)
async def add_academic_data(data: AcademicData):
    academics_collection = app.mongodb["academics"]
    students_collection = app.mongodb["Students"]

    if not await students_collection.find_one({"UserID": data.studentId}):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Student with ID {data.studentId} not found."
        )

    try:
        doc = data.dict()
        doc["createdAt"] = datetime.utcnow()   # ✅ timestamp
        await academics_collection.insert_one(doc)

        return {"status": "success", "message": "Academic data added successfully."}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error saving academic data: {str(e)}"
        )

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




@app.get("/academics/latest/{studentId}", response_description="Get latest academic data for a student")
async def get_latest_academic(studentId: str):
    """Fetches the most recent academic performance entry for a student."""
    academics_collection = app.mongodb["academics"]

    record = await academics_collection.find_one(
        {"studentId": studentId},
        sort=[("createdAt", -1)]  # ✅ newest entry first
    )

    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No academic data found for student {studentId}"
        )

    record["_id"] = str(record["_id"])  # Convert ObjectId to string
    return {"status": "success", "data": record}


from fastapi import Body

# === Update a subject inside latest academic record ===
@app.put("/academics/{studentId}/subjects/{index}", response_description="Update a subject")
async def update_subject(studentId: str, index: int, updated_subject: Subject = Body(...)):
    academics_collection = app.mongodb["academics"]

    # Find latest academic record
    record = await academics_collection.find_one(
        {"studentId": studentId},
        sort=[("createdAt", -1)]
    )

    if not record:
        raise HTTPException(status_code=404, detail="No academic data found")

    subjects = record.get("subjects", [])
    if index < 0 or index >= len(subjects):
        raise HTTPException(status_code=400, detail="Invalid subject index")

    # Update subject
    subjects[index] = updated_subject.dict()

    await academics_collection.update_one(
        {"_id": record["_id"]},
        {"$set": {"subjects": subjects}}
    )

    return {"status": "success", "message": "Subject updated successfully"}


# === Delete a subject inside latest academic record ===
@app.delete("/academics/{studentId}/subjects/{index}", response_description="Delete a subject")
async def delete_subject(studentId: str, index: int):
    academics_collection = app.mongodb["academics"]

    # Find latest academic record
    record = await academics_collection.find_one(
        {"studentId": studentId},
        sort=[("createdAt", -1)]
    )

    if not record:
        raise HTTPException(status_code=404, detail="No academic data found")

    subjects = record.get("subjects", [])
    if index < 0 or index >= len(subjects):
        raise HTTPException(status_code=400, detail="Invalid subject index")

    # Remove subject
    subjects.pop(index)

    await academics_collection.update_one(
        {"_id": record["_id"]},
        {"$set": {"subjects": subjects}}
    )

    return {"status": "success", "message": "Subject deleted successfully"}



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



@app.put("/student/{admission_no}")
async def update_student_by_admission_no(admission_no: str, updated_data: dict):
    Students_collection = app.mongodb["Students"]

    # Fields that cannot be changed
    immutable_fields = ["Admission No", "UserID", "Password"]

    # Remove them if present in request
    for field in immutable_fields:
        updated_data.pop(field, None)

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
    students_collection = app.mongodb["Students"]

    # Fix timezone issue by adjusting for the 3-hour offset
    # This is a temporary fix until we update all datetime.utcnow() calls
    cursor = logins_collection.find().sort("time", -1).limit(15)
    last_logins = []
    count = 0
    
    async for login in cursor:
        # Adjust for timezone offset (subtract 3 hours)
        adjusted_time = login["time"] - timedelta(hours=3)
        
        username = login["username"]
        role = login["role"]
        student_name = "Unknown"
        
        # Only look up student name for student roles
        if role == "student":
            student = await students_collection.find_one({"UserID": username})
            if student and "Student Name" in student:
                student_name = student["Student Name"]
        elif role == "admin":
            student_name = "Admin User"
        else:
            student_name = f"{role.title()} User"
        
        login_entry = {
            "username": username,
            "role": role,
            "time": adjusted_time.strftime("%Y-%m-%d %H:%M:%S"),
            "studentName": student_name
        }
        
        last_logins.append(login_entry)
        count += 1
        
        # Only take the first 10 after adjustment
        if count >= 10:
            break

    return {"last_logins": last_logins}


@app.get("/weekly-app-usage", response_description="Get login statistics for the past week")
async def get_weekly_app_usage():
    """Return login statistics for all students for the past week."""
    logins_coll = app.mongodb["logins"]
    
    # Calculate date range for the past 7 days
    end_date = datetime.utcnow().date()
    start_date = end_date - timedelta(days=7)
    
    # Initialize data structure for each day of the week
    daily_stats = {}
    for i in range(7):
        date = start_date + timedelta(days=i)
        daily_stats[date.isoformat()] = {
            "date": date.isoformat(),
            "entryCount": 0
        }
    
    # Fetch login data for the past week
    cursor = logins_coll.find({
        "time": {
            "$gte": datetime(start_date.year, start_date.month, start_date.day),
            "$lte": datetime(end_date.year, end_date.month, end_date.day)
        }
    })
    
    # Count entries per day
    async for record in cursor:
        login_date = record["time"].date().isoformat()
        if login_date in daily_stats:
            daily_stats[login_date]["entryCount"] += 1
    
    # Convert to list format
    daily_entries = list(daily_stats.values())
    
    # Calculate statistics
    entry_counts = [day["entryCount"] for day in daily_entries]
    total_entries = sum(entry_counts)
    average_entries = total_entries / len(entry_counts) if entry_counts else 0
    highest_entries = max(entry_counts) if entry_counts else 0
    
    return {
        "daily_entries": daily_entries,
        "statistics": {
            "total_entries": total_entries,
            "average_entries": round(average_entries, 2),
            "highest_entries": highest_entries
        }
    }


# ==========================
# Recommendations
# ==========================

# @app.get("/recommendations/{studentId}", response_description="Get AI-generated recommendations")
# async def get_recommendations(studentId: str):
#     students_coll = app.mongodb["Students"]
#     academics_coll = app.mongodb["academics"]
#     phone_coll = app.mongodb["PhoneUsage"]

#     # Verify student exists
#     student = await students_coll.find_one({"UserID": studentId})
#     if not student:
#         raise HTTPException(status_code=404, detail="Student not found")

#     # 1️⃣ Fetch latest academic record
#     academic = await academics_coll.find_one(
#         {"studentId": studentId},
#         sort=[("createdAt", -1)]
#     )
#     if not academic:
#         raise HTTPException(status_code=404, detail="No academic data found")

#     # Compute average mark
#     subjects = academic.get("subjects", [])
#     marks = [s.get("mark", 0) for s in subjects]
#     avg_mark = sum(marks) / len(marks) if marks else 0

#     # Study hours & focus level (assume numeric)
#     try:
#         study_hours = float(academic.get("studyHours", 0))
#         focus_level = float(academic.get("focusLevel", 0))
#     except:
#         study_hours = 0
#         focus_level = 0

#     # 2️⃣ Fetch last 14 days of phone usage
#     today = datetime.utcnow().date()
#     start_date = today - timedelta(days=14)

#     phone_cursor = phone_coll.find({
#         "studentId": studentId,
#         "date": {"$gte": datetime(start_date.year, start_date.month, start_date.day)}
#     })
#     phone_data = []
#     async for doc in phone_cursor:
#         phone_data.append(doc)

#     # Compute wellness metrics
#     screen_times = [d.get("screenTime", 0) for d in phone_data]
#     night_usages = [d.get("nightUsage", 0) for d in phone_data]
#     academic_app_ratio_list = []
#     for d in phone_data:
#         apps = d.get("appsUsed", [])
#         if apps:
#             total = sum(a["durationMinutes"] for a in apps)
#             academic_time = sum(a["durationMinutes"] for a in apps if a["appName"] in ["Google Classroom","Zoom","Docs","Google Meet","Khan Academy","Coursera"])
#             academic_app_ratio_list.append(academic_time / total if total > 0 else 0)

#     avg_screen = sum(screen_times)/len(screen_times) if screen_times else 0
#     avg_night = sum(night_usages)/len(night_usages) if night_usages else 0
#     avg_academic_ratio = sum(academic_app_ratio_list)/len(academic_app_ratio_list) if academic_app_ratio_list else 0

#     # 3️⃣ Generate recommendations
#     recommendations = []

#     # Academic recommendations
#     if avg_mark < 50:
#         recommendations.append("Increase study hours & focus on weak subjects.")
#     elif avg_mark < 75:
#         recommendations.append("Maintain study routine; try active recall.")
#     else:
#         recommendations.append("Excellent marks! Keep up the good work.")

#     if study_hours < 2:
#         recommendations.append("Try to study at least 2 hours daily for better performance.")
#     if focus_level < 6:
#         recommendations.append("Improve focus during study sessions; reduce distractions.")

#     # Wellness recommendations
#     if avg_screen > 360:
#         recommendations.append("Reduce total screen time; avoid prolonged phone usage.")
#     if avg_night > 120:
#         recommendations.append("Avoid night-time phone usage; maintain proper sleep schedule.")
#     if avg_academic_ratio < 0.3:
#         recommendations.append("Use more educational apps to enhance focus.")

#     return {
#         "studentId": studentId,
#         "averageMark": round(avg_mark,1),
#         "avgStudyHours": round(study_hours,1),
#         "avgFocusLevel": round(focus_level,1),
#         "avgScreenTime": round(avg_screen,1),
#         "avgNightUsage": round(avg_night,1),
#         "avgAcademicAppRatio": round(avg_academic_ratio,2),
#         "recommendations": recommendations
#     }



# from fastapi import APIRouter
# from datetime import datetime

# router = APIRouter()

# ===============================
# Generate and save recommendations
# ===============================
# @app.post("/recommendations/generate_all", response_description="Generate recommendations for all students")
# async def generate_all_recommendations():
#     students_coll = app.mongodb["Students"]
#     academics_coll = app.mongodb["academics"]
#     phone_coll = app.mongodb["PhoneUsage"]
#     rec_coll = app.mongodb["recommendations"]

#     students_cursor = students_coll.find({})
#     count = 0

#     async for student in students_cursor:
#         student_id = student.get("UserID")
#         if not student_id:
#             continue

#         # --- Fetch latest academic data ---
#         academic_records = academics_coll.find({"studentId": student_id})
#         total_marks = 0
#         total_study_hours = 0
#         total_focus = 0
#         num_records = 0
#         async for rec in academic_records:
#             subjects = rec.get("subjects", [])
#             if subjects:
#                 total_marks += sum(s.get("mark", 0) for s in subjects) / len(subjects)
#             total_study_hours += float(rec.get("studyHours", 0))
#             total_focus += float(rec.get("focusLevel", 0))
#             num_records += 1

#         if num_records == 0:
#             continue  # skip students with no academic data

#         avg_mark = total_marks / num_records
#         avg_study_hours = total_study_hours / num_records
#         avg_focus = total_focus / num_records

#         # --- Fetch last 14 days of phone usage ---
#         end_date = datetime.utcnow().date() - timedelta(days=1)
#         start_date = end_date - timedelta(days=13)
#         phone_cursor = phone_coll.find({
#             "studentId": student_id,
#             "date": {"$gte": datetime(start_date.year, start_date.month, start_date.day),
#                      "$lte": datetime(end_date.year, end_date.month, end_date.day)}
#         })

#         total_screen = 0
#         total_night = 0
#         total_academic_ratio = 0
#         phone_days = 0

#         async for day in phone_cursor:
#             screen = day.get("screenTime", 0)
#             night = day.get("nightUsage", 0)
#             apps = day.get("appsUsed", [])
#             academic_minutes = sum(a.get("durationMinutes", 0) for a in apps if a.get("appName") in [
#                 "Google Classroom", "Zoom", "Docs", "Google Meet", "Khan Academy", "Coursera"])
#             academic_ratio = academic_minutes / screen if screen > 0 else 0

#             total_screen += screen
#             total_night += night
#             total_academic_ratio += academic_ratio
#             phone_days += 1

#         if phone_days == 0:
#             avg_screen = 0
#             avg_night = 0
#             avg_academic_ratio = 0
#         else:
#             avg_screen = total_screen / phone_days
#             avg_night = total_night / phone_days
#             avg_academic_ratio = total_academic_ratio / phone_days

#         # --- Generate recommendations ---
#         recs = []

#         if avg_mark < 60:
#             recs.append("Maintain study routine; try active recall.")
#         if avg_focus < 5:
#             recs.append("Improve focus during study sessions; reduce distractions.")
#         if avg_night > 90:
#             recs.append("Avoid late-night phone usage to improve sleep.")
#         if avg_academic_ratio < 0.5:
#             recs.append("Increase use of academic apps to boost productivity.")

#         # --- Save to recommendations collection ---
#         doc = {
#             "studentId": student_id,
#             "averageMark": round(avg_mark, 2),
#             "avgStudyHours": round(avg_study_hours, 2),
#             "avgFocusLevel": round(avg_focus, 2),
#             "avgScreenTime": round(avg_screen, 2),
#             "avgNightUsage": round(avg_night, 2),
#             "avgAcademicAppRatio": round(avg_academic_ratio, 2),
#             "recommendations": recs,
#             "generatedAt": datetime.utcnow()
#         }

#         await rec_coll.update_one({"studentId": student_id}, {"$set": doc}, upsert=True)
#         count += 1

#     return {"status": "success", "message": f"Generated recommendations for {count} students."}




# 
from fastapi import HTTPException
from datetime import datetime, timedelta, timezone

@app.get("/recommendations/{studentId}", response_description="Get or generate recommendations for a student")
async def get_or_generate_recommendation(studentId: str):
    students_coll = app.mongodb["Students"]
    academics_coll = app.mongodb["academics"]
    phone_coll = app.mongodb["PhoneUsage"]
    rec_coll = app.mongodb["recommendations"]

    # 1️⃣ Check if student exists
    student = await students_coll.find_one({"UserID": studentId})
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    # 2️⃣ Fetch ONLY the latest academic record for the student
    latest_academic = await academics_coll.find_one(
        {"studentId": studentId},
        sort=[("createdAt", -1)]  # Get the most recent record
    )

    if not latest_academic:
        raise HTTPException(status_code=404, detail="No academic data found for this student")

    # Use only the latest academic data
    current_mark = latest_academic.get("overallMark", 0)
    
    # Handle potential empty string values for study hours and focus level
    study_hours_str = latest_academic.get("studyHours", "0")
    focus_level_str = latest_academic.get("focusLevel", "0")
    
    # Convert to float with proper error handling
    try:
        current_study_hours = float(study_hours_str) if study_hours_str else 0.0
    except (ValueError, TypeError):
        current_study_hours = 0.0
        
    try:
        current_focus = float(focus_level_str) if focus_level_str else 0.0
    except (ValueError, TypeError):
        current_focus = 0.0

    # 3️⃣ Fetch last 14 days of phone usage
    today = datetime.utcnow().date()
    start_date = today - timedelta(days=14)

    phone_cursor = phone_coll.find({
        "studentId": studentId,
        "date": {"$gte": datetime(start_date.year, start_date.month, start_date.day)}
    })

    total_screen = 0
    total_night = 0
    total_academic_ratio = 0
    phone_days = 0

    async for day in phone_cursor:
        screen = day.get("screenTime", 0)
        night = day.get("nightUsage", 0)
        apps = day.get("appsUsed", [])
        academic_minutes = sum(
            a.get("durationMinutes", 0) for a in apps
            if a.get("appName") in ["Google Classroom","Zoom","Docs","Google Meet","Khan Academy","Coursera"]
        )
        academic_ratio = academic_minutes / screen if screen > 0 else 0

        total_screen += screen
        total_night += night
        total_academic_ratio += academic_ratio
        phone_days += 1

    if phone_days == 0:
        avg_screen = 0
        avg_night = 0
        avg_academic_ratio = 0
    else:
        avg_screen = total_screen / phone_days
        avg_night = total_night / phone_days
        avg_academic_ratio = total_academic_ratio / phone_days

    # 4️⃣ Generate ONE main recommendation with specific action steps
    # Determine the most critical issue to focus on
    
    main_title = ""
    main_description = ""
    main_reason = ""
    action_steps = []
    
    # Priority 1: Academic Performance (most critical)
    if current_mark < 50:
        main_title = "Urgent Academic Improvement Needed"
        main_description = "Your current academic performance shows significant room for improvement. Focus on strengthening your study foundation and building consistent learning habits."
        main_reason = f"Your current average mark is {current_mark:.1f}%, which is below the recommended threshold. Immediate action will help you get back on track."
        action_steps = [
            "Schedule 3-4 hours of focused daily study time",
            "Identify and prioritize your 2 weakest subjects",
            "Create a weekly study timetable with specific goals",
            "Seek help from teachers or tutors for difficult topics",
            "Practice past papers and mock tests regularly"
        ]
    elif current_mark < 70:
        main_title = "Boost Your Academic Performance"
        main_description = "You're making good progress, but there's potential to achieve even better results with some focused improvements to your study strategy."
        main_reason = f"Your current average mark is {current_mark:.1f}%. With targeted effort, you can reach the next performance level."
        action_steps = [
            "Increase daily study time to 2-3 hours",
            "Use active recall techniques instead of passive reading",
            "Form study groups for challenging subjects",
            "Review and revise topics weekly",
            "Set specific grade targets for each subject"
        ]
    # Priority 2: Focus and Study Habits
    elif current_focus < 5:
        main_title = "Enhance Your Focus and Concentration"
        main_description = "Your study focus needs improvement to maximize learning efficiency. Better concentration will help you absorb more information in less time."
        main_reason = f"Your current focus level is {current_focus:.1f}/10, which may be limiting your academic potential."
        action_steps = [
            "Create a distraction-free study environment",
            "Use the Pomodoro technique (25 min study + 5 min break)",
            "Keep your phone in another room during study time",
            "Practice mindfulness or meditation for 10 minutes daily",
            "Take regular breaks to maintain mental freshness"
        ]
    # Priority 3: Study Time Management
    elif current_study_hours < 2:
        main_title = "Increase Your Daily Study Time"
        main_description = "Consistent daily study habits are key to academic success. Building a regular study routine will improve your learning outcomes significantly."
        main_reason = f"You're currently studying {current_study_hours:.1f} hours daily, which may not be sufficient for optimal performance."
        action_steps = [
            "Gradually increase study time to 2-3 hours daily",
            "Create a fixed daily study schedule",
            "Break study sessions into manageable chunks",
            "Track your daily study hours to build consistency",
            "Reward yourself for meeting daily study goals"
        ]
    # Priority 4: Digital Wellness (Screen Time)
    elif avg_screen > 360:  # More than 6 hours
        main_title = "Optimize Your Digital Wellness"
        main_description = "High screen time may be affecting your sleep quality, focus, and overall well-being. Creating a healthier relationship with technology will boost your academic performance."
        main_reason = f"You're spending {avg_screen/60:.1f} hours daily on your phone, which can impact concentration and sleep."
        action_steps = [
            "Set a daily screen time limit of 4-5 hours maximum",
            "Use app timers to control social media usage",
            "Replace phone time with physical activities",
            "Keep phones away during study and sleep time",
            "Find offline hobbies like reading or sports"
        ]
    # Priority 5: Sleep Optimization
    elif avg_night > 120:  # More than 2 hours night usage
        main_title = "Improve Your Sleep Quality"
        main_description = "Late-night phone usage is disrupting your sleep patterns, which directly affects your memory consolidation and next-day focus for studying."
        main_reason = f"You're using your phone {avg_night:.0f} minutes nightly, which can harm sleep quality and academic performance."
        action_steps = [
            "Stop phone usage 1 hour before bedtime",
            "Create a relaxing bedtime routine",
            "Aim for 7-8 hours of quality sleep nightly",
            "Keep your phone outside the bedroom",
            "Use a physical alarm clock instead of phone"
        ]
    # Priority 6: Academic App Usage
    elif avg_academic_ratio < 0.3:
        main_title = "Leverage Technology for Learning"
        main_description = "Make your screen time more productive by using educational apps and resources that can enhance your academic performance."
        main_reason = f"Only {avg_academic_ratio*100:.1f}% of your phone time is spent on educational content. Increasing this can boost learning."
        action_steps = [
            "Download educational apps for your subjects",
            "Watch educational YouTube channels daily",
            "Use online study platforms like Khan Academy",
            "Join virtual study groups and online classes",
            "Replace entertainment apps with learning tools"
        ]
    else:
        # Excellent performance - maintain and optimize
        main_title = "Maintain Your Excellent Progress"
        main_description = "You're doing great! Continue with your current approach while exploring ways to enhance your learning experience even further."
        main_reason = f"Your current performance metrics are excellent. Focus on maintaining consistency and exploring advanced learning techniques."
        action_steps = [
            "Continue your current study routine",
            "Explore advanced learning techniques",
            "Help other students to reinforce your knowledge",
            "Set challenging academic goals for yourself",
            "Maintain a healthy work-life balance"
        ]
    
    main_recommendation = {
        "title": main_title,
        "description": main_description,
        "reason": main_reason,
        "actionable_steps": action_steps
    }

    # 5️⃣ Extra tips (static for now)
    extra_tips = [
        {"title": "Morning Brain Boost", "tip": "Start your day with breakfast and 10 minutes light exercise", "icon": "breakfast_dining"},
        {"title": "Pomodoro Study", "tip": "25 min study + 5 min break", "icon": "timer"},
        {"title": "Stress Relief", "tip": "5 deep breaths or 2 min walk when stressed", "icon": "spa"},
        {"title": "Hydration Reminder", "tip": "Keep a water bottle at your desk", "icon": "local_drink"},
        {"title": "Social Learning", "tip": "Explain concepts to peers weekly", "icon": "group"}
    ]

    # 6️⃣ Save or update recommendation in MongoDB
    doc = {
        "studentId": studentId,
        "currentMark": round(current_mark, 2),
        "currentStudyHours": round(current_study_hours, 2),
        "currentFocusLevel": round(current_focus, 2),
        "avgScreenTime": round(avg_screen, 2),
        "avgNightUsage": round(avg_night, 2),
        "avgAcademicAppRatio": round(avg_academic_ratio, 2),
        "main_recommendation": main_recommendation,
        "extra_tips": extra_tips,
        "generatedAt": datetime.utcnow()
    }

    await rec_coll.update_one({"studentId": studentId}, {"$set": doc}, upsert=True)

    # Fetch the inserted/updated document
    saved_doc = await rec_coll.find_one({"studentId": studentId})
    saved_doc["_id"] = str(saved_doc["_id"])

    return saved_doc
