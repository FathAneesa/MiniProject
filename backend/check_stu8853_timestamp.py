import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime

# Load environment variables
load_dotenv()

async def check_stu8853_timestamp():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Find the most recent login for STU8853
        logins_collection = database["logins"]
        
        recent_login = await logins_collection.find_one(
            {"username": "STU8853"},
            sort=[("time", -1)]
        )
        
        if recent_login:
            login_time = recent_login["time"]
            print(f"STU8853 most recent login timestamp: {login_time}")
            print(f"Type of timestamp: {type(login_time)}")
            
            # Check if it's timezone aware
            if hasattr(login_time, 'tzinfo'):
                print(f"Timezone info: {login_time.tzinfo}")
            
            # Try to convert to local time for comparison
            current_time = datetime.utcnow()
            print(f"Current UTC time: {current_time}")
            
            # Calculate difference
            if isinstance(login_time, datetime):
                time_diff = current_time - login_time
                print(f"Time difference: {time_diff}")
                print(f"Minutes ago: {time_diff.total_seconds() / 60:.2f}")
            else:
                print("Timestamp is not a datetime object")
        else:
            print("No login found for STU8853")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_stu8853_timestamp())