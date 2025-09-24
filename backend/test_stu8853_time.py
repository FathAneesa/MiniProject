import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta

# Load environment variables
load_dotenv()

async def test_stu8853_time():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Find STU8853's most recent login
        logins_collection = database["logins"]
        
        login = await logins_collection.find_one(
            {"username": "STU8853"},
            sort=[("time", -1)]
        )
        
        if not login:
            print("❌ STU8853 not found in logins collection")
            return
            
        # Show the raw timestamp from database
        raw_time = login["time"]
        print(f"STU8853 raw timestamp from database: {raw_time}")
        
        # Show adjusted time (subtracting 3 hours)
        adjusted_time = raw_time - timedelta(hours=3)
        print(f"STU8853 adjusted timestamp: {adjusted_time}")
        
        # Calculate time difference from now
        current_time = datetime.utcnow()
        print(f"Current UTC time: {current_time}")
        
        # Time difference with raw timestamp
        raw_diff = current_time - raw_time
        print(f"Time difference (raw): {raw_diff} ({raw_diff.total_seconds()/60:.2f} minutes ago)")
        
        # Time difference with adjusted timestamp
        adjusted_diff = current_time - adjusted_time
        print(f"Time difference (adjusted): {adjusted_diff} ({adjusted_diff.total_seconds()/60:.2f} minutes ago)")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_stu8853_time())