# create_admin_user.py
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME", "wellnessDB")

async def create_admin_user():
    if not MONGO_URI:
        print("❌ MONGO_URI is not set in .env file")
        return
    
    try:
        client = AsyncIOMotorClient(MONGO_URI)
        db = client[DB_NAME]
        
        # Check if admin user already exists
        existing_user = await db["Users"].find_one({"username": "admin"})
        if existing_user:
            print("✅ Admin user already exists")
            client.close()
            return
        
        # Create admin user
        admin_user = {
            "username": "admin",
            "password": "admin123",
            "role": "admin"
        }
        
        result = await db["Users"].insert_one(admin_user)
        print(f"✅ Admin user created successfully with ID: {result.inserted_id}")
        client.close()
        
    except Exception as e:
        print(f"❌ Error creating admin user: {e}")

if __name__ == "__main__":
    asyncio.run(create_admin_user())