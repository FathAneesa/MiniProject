# exact_flutter_test.py
import requests
import json

def test_exact_flutter_behavior():
    """
    This test mimics exactly what the Flutter app is doing:
    1. Using the same URL format
    2. Using the same headers
    3. Using the same JSON encoding
    """
    
    # This is what the Flutter app is doing
    api_base_url = 'http://127.0.0.1:8081'  # This matches our config.dart
    url = f'{api_base_url}/login'
    
    # Test with the anjana user we know exists
    username = "anjana"
    password = "anjana"  # We don't know the real password
    
    headers = {'Content-Type': 'application/json'}
    body = json.dumps({'username': username, 'password': password})
    
    print(f"Testing exact Flutter behavior")
    print(f"URL: {url}")
    print(f"Headers: {headers}")
    print(f"Body: {body}")
    
    try:
        # This is exactly what the Flutter app does
        response = requests.post(
            url,
            headers=headers,
            data=body,  # Flutter uses 'body' parameter
            timeout=10  # Flutter has a 10 second timeout
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            print("✅ Would succeed in Flutter")
            data = response.json()
            print(f"Data: {data}")
        else:
            print("❌ Would fail in Flutter")
            # Check what kind of error this would trigger in Flutter
            if response.status_code == 401:
                print("This would show: 'Error during login' message in Flutter")
            else:
                print("This might trigger the ClientException in Flutter")
                
    except requests.exceptions.ConnectionError as e:
        print(f"❌ This would trigger ClientException in Flutter: {e}")
        print("This would show: 'Cannot connect to server. Is it running?'")
    except requests.exceptions.Timeout as e:
        print(f"❌ This would trigger TimeoutException in Flutter: {e}")
        print("This would show: 'Connection timed out. Please check your network.'")
    except Exception as e:
        print(f"❌ This would trigger generic Exception in Flutter: {e}")
        print("This would show: 'An unexpected error occurred: $e'")

if __name__ == "__main__":
    test_exact_flutter_behavior()