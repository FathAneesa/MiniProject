import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta

# Load environment variables
load_dotenv()

async def test_monitor_extended():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Test the fixed monitor logic with more entries
        logins_collection = database["logins"]
        students_collection = database["Students"]

        # Get more entries to see if STU8853 appears
        cursor = logins_collection.find().sort("time", -1).limit(25)
        last_logins = []
        count = 0
        stu8853_found = False
        
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
            
            # Check if STU8853 is in the results
            if username == "STU8853":
                stu8853_found = True
            
            # Stop after 25 entries
            if count >= 25:
                break

        print("Extended monitor results (last 25 logins with timezone adjustment):")
        for i, login in enumerate(last_logins, 1):
            marker = ""
            if login["username"] == "STU8853":
                marker = " ← STU8853 (FOUND!)"
            print(f"  {i:2d}. {login['username']:10} | {login['time']} | {login['studentName']}{marker}")
        
        if not stu8853_found:
            print("\n🔍 STU8853 not found in the last 25 logins!")
        else:
            print("\n✅ STU8853 was found in the results!")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_monitor_extended())