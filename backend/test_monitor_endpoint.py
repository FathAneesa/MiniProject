import requests
import json

try:
    response = requests.get("http://localhost:8081/monitor")
    if response.status_code == 200:
        data = response.json()
        print("Monitor endpoint response:")
        print(json.dumps(data, indent=2))
    else:
        print(f"Error: {response.status_code}")
except Exception as e:
    print(f"Error: {e}")