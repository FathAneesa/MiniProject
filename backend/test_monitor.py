import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

# Load environment variables
load_dotenv()

async def test_monitor_query():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        print(f"✅ Connected to database: {DB_NAME}")
        
        # Test the same query as in the monitor endpoint
        logins_collection = database["logins"]
        students_collection = database["Students"]
        
        print("\nTesting monitor query...")
        cursor = logins_collection.find().sort("time", -1).limit(10)
        last_logins = []
        async for login in cursor:
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
            
            last_logins.append({
                "username": username,
                "role": role,
                "time": login["time"].strftime("%Y-%m-%d %H:%M:%S"),
                "studentName": student_name
            })
            print(f"Username: {username}, Role: {role}, Time: {login['time'].strftime('%Y-%m-%d %H:%M:%S')}, Name: {student_name}")
        
        print(f"\nTotal records found: {len(last_logins)}")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_monitor_query())