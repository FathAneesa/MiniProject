import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime

# Load environment variables
load_dotenv()

async def check_actual_last_15_logins():
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
        
        # Get the actual last 15 logins from the database
        cursor = logins_collection.find().sort("time", -1).limit(15)
        print("Actual last 15 login activities from database:")
        count = 0
        stu8853_found = False
        async for login in cursor:
            count += 1
            time_diff = datetime.utcnow() - login["time"]
            marker = ""
            
            # Check if this is STU8853
            if login["username"] == "STU8853":
                marker = " ← STU8853"
                stu8853_found = True
            
            print(f"  {count:2d}. {login['username']:10} | {login['time']} | "
                  f"{time_diff.total_seconds()/60:.2f} min ago{marker}")
            
            # Stop after 15 to see more context
            if count >= 15:
                break
        
        if not stu8853_found:
            print("\n🔍 STU8853 not found in the last 15 logins!")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_actual_last_15_logins())