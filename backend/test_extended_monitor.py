import requests
import json

# Test the extended monitor endpoint to see if STU8853 appears
try:
    # First, let's check if we can modify the limit in the request
    # Since we can't directly modify the endpoint, let's create a test that mimics what we did in our fix
    
    response = requests.get("http://localhost:8081/monitor")
    if response.status_code == 200:
        data = response.json()
        logins = data.get("last_logins", [])
        print("Current monitor endpoint (last 10 logins):")
        for i, login in enumerate(logins, 1):
            marker = ""
            if login["username"] == "STU8853":
                marker = " ← STU8853"
            print(f"  {i:2d}. {login['username']:10} | {login['time']} | {login['studentName']}{marker}")
        
        # Check if STU8853 is in the list
        stu8853_found = any(login["username"] == "STU8853" for login in logins)
        if stu8853_found:
            print("\n✅ STU8853 is in the top 10 logins!")
        else:
            print("\n🔍 STU8853 is not in the top 10 logins (as expected based on our earlier analysis)")
    else:
        print(f"Error: {response.status_code}")
except Exception as e:
    print(f"Error: {e}")