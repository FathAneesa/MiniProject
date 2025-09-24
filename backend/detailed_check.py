import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

async def detailed_check():
    # Connect to MongoDB
    MONGO_DETAILS = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    client = AsyncIOMotorClient(MONGO_DETAILS)
    database = client[DB_NAME]
    
    # Check logins collection
    logins_collection = database["logins"]
    
    print("Checking recent login records (last 24 hours)...")
    # Calculate time 24 hours ago
    time_24_hours_ago = datetime.utcnow() - timedelta(hours=24)
    
    # Get recent logins
    cursor = logins_collection.find({
        "time": {"$gte": time_24_hours_ago}
    }).sort("time", -1)
    
    recent_count = 0
    async for login in cursor:
        recent_count += 1
        print(f"Username: {login['username']}, Role: {login['role']}, Time: {login['time']}")
    
    print(f"\nTotal recent login records (last 24 hours): {recent_count}")
    
    # Check specific recent users
    print("\nChecking for recent logins of specific users...")
    time_1_hour_ago = datetime.utcnow() - timedelta(hours=1)
    
    # Check for recent admin login
    recent_admin = await logins_collection.find_one({
        "username": "anjana",
        "time": {"$gte": time_1_hour_ago}
    })
    if recent_admin:
        print(f"Recent admin login found: {recent_admin}")
    else:
        print("No recent admin login found (within last hour)")
    
    # Check for recent student login
    recent_student = await logins_collection.find_one({
        "username": "STU8853",
        "time": {"$gte": time_1_hour_ago}
    })
    if recent_student:
        print(f"Recent STU8853 login found: {recent_student}")
    else:
        print("No recent STU8853 login found (within last hour)")
    
    client.close()

if __name__ == "__main__":
    asyncio.run(detailed_check())