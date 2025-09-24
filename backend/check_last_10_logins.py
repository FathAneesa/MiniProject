import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

# Load environment variables
load_dotenv()

async def check_last_10_logins():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Check the logins collection
        logins_collection = database["logins"]
        students_collection = database["Students"]
        
        # Get exactly the same query as the monitor endpoint
        cursor = logins_collection.find().sort("time", -1).limit(10)
        print("Last 10 login activities:")
        count = 0
        async for login in cursor:
            count += 1
            username = login["username"]
            role = login["role"]
            student_name = "Unknown"
            
            # Same logic as monitor endpoint
            if role == "student":
                student = await students_collection.find_one({"UserID": username})
                if student and "Student Name" in student:
                    student_name = student["Student Name"]
            elif role == "admin":
                student_name = "Admin User"
            else:
                student_name = f"{role.title()} User"
            
            print(f"{count:2d}. Username: {username:10} | Role: {role:6} | Time: {login['time'].strftime('%Y-%m-%d %H:%M:%S')} | Name: {student_name}")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_last_10_logins())