import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

async def check_logins():
    # Connect to MongoDB
    MONGO_DETAILS = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    client = AsyncIOMotorClient(MONGO_DETAILS)
    database = client[DB_NAME]
    
    # Check logins collection
    logins_collection = database["logins"]
    
    print("Checking login records...")
    count = await logins_collection.count_documents({})
    print(f"Total login records: {count}")
    
    # Get recent logins
    cursor = logins_collection.find().sort("time", -1).limit(10)
    async for login in cursor:
        print(f"Username: {login['username']}, Role: {login['role']}, Time: {login['time']}")
    
    # Check specific users
    print("\nChecking specific users...")
    admin_login = await logins_collection.find_one({"username": "anjana"})
    if admin_login:
        print(f"Admin login found: {admin_login}")
    else:
        print("No admin login found")
    
    student_login = await logins_collection.find_one({"username": "STU8853"})
    if student_login:
        print(f"Student STU8853 login found: {student_login}")
    else:
        print("No STU8853 login found")
    
    client.close()

if __name__ == "__main__":
    asyncio.run(check_logins())