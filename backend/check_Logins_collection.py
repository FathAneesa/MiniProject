import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

# Load environment variables
load_dotenv()

async def check_Logins_collection():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # Check the Logins collection (capitalized)
        logins_collection = database["Logins"]
        count = await logins_collection.count_documents({})
        print(f"Logins collection (capitalized) has {count} documents")
        
        # Show all documents
        cursor = logins_collection.find()
        async for doc in cursor:
            print(f"  {doc}")
        
        # Check the logins collection (lowercase)
        logins_collection_lower = database["logins"]
        count_lower = await logins_collection_lower.count_documents({})
        print(f"\nlogins collection (lowercase) has {count_lower} documents")
        
        # Show recent documents from lowercase collection
        print("\nRecent documents from logins (lowercase):")
        cursor = logins_collection_lower.find().sort("time", -1).limit(5)
        async for doc in cursor:
            print(f"  {doc}")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_Logins_collection())