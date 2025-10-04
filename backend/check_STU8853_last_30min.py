import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta

# Load environment variables
load_dotenv()

async def check_STU8853_recent_logins():
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
        
        # Find all logins for STU8853 in the last 30 minutes
        time_30_min_ago = datetime.utcnow() - timedelta(minutes=30)
        
        cursor = logins_collection.find({
            "username": "STU8853",
            "time": {"$gte": time_30_min_ago}
        }).sort("time", -1)
        
        print(f"STU8853 logins in the last 30 minutes (since {time_30_min_ago}):")
        count = 0
        async for login in cursor:
            count += 1
            time_diff = datetime.utcnow() - login["time"]
            print(f"  {count}. Time: {login['time']} ({time_diff.total_seconds()/60:.2f} minutes ago)")
        
        if count == 0:
            print("  No recent logins found")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_STU8853_recent_logins())