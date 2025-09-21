# populate_test_data.py
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime

MONGO_URI = "mongodb+srv://anjana:ijvyAnVldjuaQZ0W@cluster0.sfm1e8w.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"  # same as in your .env
DB_NAME = "wellnessDB"

async def main():
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[DB_NAME]

    # --- Students ---
    students = [
        {
            "Admission No": "ADM001",
            "Name": "John Doe",
            "dob": "2005-03-15",
            "UserID": "STU1001",
            "Password": "15032005",
            "Class": "10"
        }
    ]
    await db["Students"].insert_many(students)

    # --- Academics ---
    academics = [
        {
            "studentId": "STU1001",
            "subjects": [
                {"name": "Math", "mark": 78},
                {"name": "Science", "mark": 65},
                {"name": "English", "mark": 82}
            ],
            "studyHours": "3",
            "focusLevel": "7",
            "overallMark": 75,
            "createdAt": datetime.utcnow()
        }
    ]
    await db["academics"].insert_many(academics)

    # --- Phone Usage (last 5 days sample) ---
    phone_usage = [
        {
            "studentId": "STU1001",
            "date": datetime(2025, 9, 20),
            "screenTime": 300,
            "nightUsage": 60,
            "appsUsed": [
                {"appName": "Google Classroom", "durationMinutes": 90},
                {"appName": "Instagram", "durationMinutes": 120},
                {"appName": "Zoom", "durationMinutes": 30}
            ]
        },
        {
            "studentId": "STU1001",
            "date": datetime(2025, 9, 19),
            "screenTime": 240,
            "nightUsage": 30,
            "appsUsed": [
                {"appName": "Google Classroom", "durationMinutes": 60},
                {"appName": "WhatsApp", "durationMinutes": 80},
                {"appName": "Docs", "durationMinutes": 20}
            ]
        },
        {
            "studentId": "STU1001",
            "date": datetime(2025, 9, 18),
            "screenTime": 360,
            "nightUsage": 90,
            "appsUsed": [
                {"appName": "Khan Academy", "durationMinutes": 120},
                {"appName": "YouTube", "durationMinutes": 60}
            ]
        }
    ]
    await db["PhoneUsage"].insert_many(phone_usage)

    print("✅ Test data inserted successfully")
    client.close()

asyncio.run(main())
