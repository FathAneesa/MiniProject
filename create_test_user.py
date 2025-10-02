import asyncio
import sys
import os
from motor.motor_asyncio import AsyncIOMotorClient
import bcrypt

# Add the backend directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend'))

# Load environment variables (if dotenv is available)
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

async def create_test_user():
    # MongoDB connection
    MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
    DB_NAME = os.getenv("DB_NAME", "wellnessDB")
    
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[DB_NAME]
    
    # Check if users collection exists and has users
    users_count = await db.users.count_documents({})
    print(f"Current number of users in database: {users_count}")
    
    # If no users exist, create a test admin user
    if users_count == 0:
        print("No users found. Creating a test admin user...")
        
        # Hash the password
        password = "Admin@123"
        hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        
        # Create admin user
        admin_user = {
            "username": "admin",
            "password": hashed_password.decode('utf-8'),
            "role": "admin",
            "name": "Admin User"
        }
        
        result = await db.users.insert_one(admin_user)
        print(f"Created admin user with ID: {result.inserted_id}")
        print(f"Login credentials: username=admin, password=Admin@123")
    else:
        print("Users already exist in the database.")
        # List first few users (without passwords)
        users = await db.users.find({}, {"password": 0}).to_list(length=5)
        for user in users:
            print(f"Username: {user.get('username')}, Role: {user.get('role')}, Name: {user.get('name')}")
    
    client.close()

if __name__ == "__main__":
    asyncio.run(create_test_user())