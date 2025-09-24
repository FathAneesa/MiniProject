import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta

# Load environment variables
load_dotenv()

async def test_monitor_fix():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Test the fixed monitor logic
        logins_collection = database["logins"]
        students_collection = database["Students"]

        # Apply the same fix as in the monitor endpoint
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

        print("Fixed monitor results (last 10 logins with timezone adjustment):")
        for i, login in enumerate(last_logins, 1):
            marker = ""
            if login["username"] == "STU8853":
                marker = " ← STU8853"
            print(f"  {i:2d}. {login['username']:10} | {login['time']} | {login['studentName']}{marker}")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_monitor_fix())