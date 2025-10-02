import sys
import os

# Add the backend directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend'))

try:
    import asyncio
    from motor.motor_asyncio import AsyncIOMotorClient
    import bcrypt
    
    async def check_users():
        # MongoDB connection (using MongoDB Atlas)
        MONGO_URI = "mongodb+srv://anjana:ijvyAnVldjuaQZ0W@cluster0.sfm1e8w.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
        DB_NAME = "wellnessDB"
        
        try:
            client = AsyncIOMotorClient(MONGO_URI, serverSelectionTimeoutMS=10000)
            db = client[DB_NAME]
            
            # Check if users collection exists and has users
            users_count = await db.users.count_documents({})
            print(f"Current number of users in database: {users_count}")
            
            if users_count > 0:
                print("Existing users:")
                # List first few users (without passwords)
                users = await db.users.find({}, {"password": 0}).to_list(length=5)
                for user in users:
                    print(f"  Username: {user.get('username')}, Role: {user.get('role')}, Name: {user.get('name')}")
            else:
                print("No users found in the database.")
                print("Creating a test admin user...")
                
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
                
        except Exception as e:
            print(f"Error connecting to database: {e}")
        finally:
            if 'client' in locals():
                client.close()

    if __name__ == "__main__":
        asyncio.run(check_users())
        
except ImportError as e:
    print(f"Missing required packages: {e}")
    print("Please install required packages:")
    print("pip install motor bcrypt")