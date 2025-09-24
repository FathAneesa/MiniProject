# test_flutter_login.py
import requests
import json

def test_login():
    # This mimics what the Flutter app is doing
    url = 'http://127.0.0.1:8081/login'
    
    # Test data - trying common passwords for the 'anjana' user
    test_credentials = [
        ("anjana", "anjana"),
        ("anjana", "admin"),
        ("anjana", "password"),
        ("anjana", "123456"),
        ("admin", "admin123"),
        ("testuser", "testpass")  # This one we know exists
    ]
    
    headers = {'Content-Type': 'application/json'}
    
    for username, password in test_credentials:
        print(f"\n--- Testing {username}/{password} ---")
        data = json.dumps({'username': username, 'password': password})
        
        try:
            print(f"Attempting to login to {url}")
            response = requests.post(url, headers=headers, data=data, timeout=10)
            
            print(f"Status Code: {response.status_code}")
            if response.status_code == 200:
                print("✅ Login successful!")
                try:
                    data = response.json()
                    print(f"Response Data: {data}")
                    return  # Exit on first successful login
                except:
                    print("Could not parse JSON response")
            else:
                print(f"❌ Login failed with status {response.status_code}")
                print(f"Response Body: {response.text}")
                
        except requests.exceptions.ConnectionError as e:
            print(f"❌ Connection Error: {e}")
        except requests.exceptions.Timeout as e:
            print(f"❌ Timeout Error: {e}")
        except Exception as e:
            print(f"❌ Other Error: {e}")

if __name__ == "__main__":
    test_login()