import asyncio
import aiohttp
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime

# Load environment variables
load_dotenv()

async def test_recent_login():
    # First, let's add a recent login record for STU8853
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Insert a very recent login for STU8853
        logins_collection = database["logins"]
        recent_time = datetime.utcnow()
        
        new_login = {
            "username": "STU8853",
            "role": "student",
            "time": recent_time
        }
        
        result = await logins_collection.insert_one(new_login)
        print(f"✅ Inserted test login for STU8853 at {recent_time}")
        print(f"   Inserted ID: {result.inserted_id}")
        
        # Now check the monitor endpoint
        print("\nChecking monitor endpoint...")
        async with aiohttp.ClientSession() as session:
            async with session.get('http://localhost:8000/monitor') as response:
                if response.status == 200:
                    data = await response.json()
                    print("\nLast 10 logins from monitor endpoint:")
                    for i, login in enumerate(data.get('last_logins', []), 1):
                        print(f"  {i:2d}. {login.get('username', 'N/A'):10} | "
                              f"{login.get('time', 'N/A')} | "
                              f"{login.get('studentName', 'N/A')}")
                        
                        # Check specifically for STU8853
                        if login.get('username') == 'STU8853':
                            print(f"     ✅ STU8853 found in monitor list!")
                else:
                    print(f"Error fetching monitor data: HTTP {response.status}")
        
        # Clean up - delete the test login
        await logins_collection.delete_one({"_id": result.inserted_id})
        print(f"\n🗑️  Cleaned up test login record")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_recent_login())