import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta

# Load environment variables
load_dotenv()

async def check_STU8853_recent_login():
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
        
        # Find the most recent login for STU8853
        recent_login = await logins_collection.find_one(
            {"username": "STU8853"},
            sort=[("time", -1)]
        )
        
        if recent_login:
            login_time = recent_login["time"]
            current_time = datetime.utcnow()
            time_diff = current_time - login_time
            
            print(f"STU8853 most recent login:")
            print(f"  Time: {login_time}")
            print(f"  Current time: {current_time}")
            print(f"  Time difference: {time_diff}")
            print(f"  Minutes ago: {time_diff.total_seconds() / 60:.2f}")
            
            # Check if this is within the last 10 minutes
            if time_diff <= timedelta(minutes=10):
                print("  ✅ This login is within the last 10 minutes!")
            else:
                print("  ❌ This login is older than 10 minutes")
        else:
            print("No login found for STU8853")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_STU8853_recent_login())