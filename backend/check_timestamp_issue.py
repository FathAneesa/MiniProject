import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta

# Load environment variables
load_dotenv()

async def check_timestamp_issue():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Get current time
        current_time = datetime.utcnow()
        print(f"Current UTC time: {current_time}")
        
        # Check logins collection
        logins_collection = database["logins"]
        
        # Count total logins
        total_logins = await logins_collection.count_documents({})
        print(f"Total login records: {total_logins}")
        
        # Count logins in the future (more than 1 hour ahead)
        future_logins = await logins_collection.count_documents({
            "time": {"$gt": current_time + timedelta(hours=1)}
        })
        print(f"Login records in the future (more than 1 hour): {future_logins}")
        
        # Count logins in the past hour
        recent_logins = await logins_collection.count_documents({
            "time": {
                "$gte": current_time - timedelta(hours=1),
                "$lte": current_time
            }
        })
        print(f"Login records in the past hour: {recent_logins}")
        
        # Count logins 3 hours ahead (the pattern we noticed)
        three_hours_ahead_logins = await logins_collection.count_documents({
            "time": {
                "$gte": current_time + timedelta(hours=2.5),
                "$lte": current_time + timedelta(hours=3.5)
            }
        })
        print(f"Login records about 3 hours ahead: {three_hours_ahead_logins}")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_timestamp_issue())