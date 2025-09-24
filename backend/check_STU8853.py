import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta

# Load environment variables
load_dotenv()

async def check_STU8853():
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
        
        # Check for STU8853 logins in the last 24 hours
        time_24_hours_ago = datetime.utcnow() - timedelta(hours=24)
        
        cursor = logins_collection.find({
            "username": "STU8853",
            "time": {"$gte": time_24_hours_ago}
        }).sort("time", -1)
        
        print("Recent logins for STU8853 (last 24 hours):")
        count = 0
        async for doc in cursor:
            count += 1
            print(f"  Time: {doc['time']}, Role: {doc['role']}")
        
        if count == 0:
            print("  No recent logins found for STU8853")
        else:
            print(f"  Total recent logins: {count}")
        
        # Check if the student exists in the Students collection
        students_collection = database["Students"]
        student = await students_collection.find_one({"UserID": "STU8853"})
        if student:
            print(f"\nStudent STU8853 found in Students collection:")
            print(f"  Name: {student.get('Student Name', 'Unknown')}")
            print(f"  Admission No: {student.get('Admission No', 'Unknown')}")
        else:
            print(f"\nStudent STU8853 NOT found in Students collection")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_STU8853())