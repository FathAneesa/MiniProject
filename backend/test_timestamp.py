import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime

# Load environment variables
load_dotenv()

async def test_timestamp():
    # Check current time
    current_time = datetime.utcnow()
    print(f"Current UTC time: {current_time}")
    
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Insert a test login record
        logins_collection = database["logins"]
        
        test_login = {
            "username": "TEST_USER",
            "role": "student",
            "time": current_time
        }
        
        result = await logins_collection.insert_one(test_login)
        print(f"✅ Inserted test login with current time")
        
        # Retrieve the record immediately
        retrieved = await logins_collection.find_one({"_id": result.inserted_id})
        if retrieved:
            stored_time = retrieved["time"]
            print(f"Stored time in database: {stored_time}")
            print(f"Difference: {stored_time - current_time}")
        
        # Clean up
        await logins_collection.delete_one({"_id": result.inserted_id})
        print("🗑️  Cleaned up test record")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_timestamp())