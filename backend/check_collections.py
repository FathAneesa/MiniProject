import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

# Load environment variables
load_dotenv()

async def check_collections():
    # Use the same connection method as main.py
    MONGO_URI = os.getenv("MONGO_URI")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        database = client[DB_NAME]
        
        # List all collections
        collections = await database.list_collection_names()
        print(f"Available collections in {DB_NAME}:")
        for collection in collections:
            print(f"  - {collection}")
        
        # Check if there are multiple login collections
        login_collections = [c for c in collections if 'login' in c.lower()]
        if login_collections:
            print(f"\nLogin-related collections found:")
            for collection in login_collections:
                count = await database[collection].count_documents({})
                print(f"  - {collection}: {count} documents")
        
        client.close()
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_collections())