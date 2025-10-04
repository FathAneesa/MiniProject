import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime

# Load environment variables
load_dotenv()

async def check_timestamp_pattern():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Get the last 5 logins with full timestamp info
        logins_collection = database["logins"]
        
        cursor = logins_collection.find().sort("time", -1).limit(5)
        current_time = datetime.utcnow()
        print(f"Current UTC time: {current_time}")
        print("\nLast 5 logins:")
        print("Rank | Username   | Timestamp               | Minutes Ago")
        print("-----|------------|-------------------------|------------")
        
        count = 0
        async for login in cursor:
            count += 1
            login_time = login["time"]
            time_diff = current_time - login_time
            minutes_ago = time_diff.total_seconds() / 60
            
            print(f"{count:4d} | {login['username']:10} | {login_time} | {minutes_ago:10.2f}")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_timestamp_pattern())