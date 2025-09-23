#!/usr/bin/env python3
"""
Test script to verify backend connectivity from different URLs
"""

import requests
import json

def test_connection(base_url):
    """Test connection to backend"""
    try:
        print(f"🔍 Testing connection to: {base_url}")
        
        # Test students endpoint
        response = requests.get(f"{base_url}/students", timeout=10)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Success! Found {len(data)} students")
            return True
        else:
            print(f"❌ HTTP Error: {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError as e:
        print(f"❌ Connection Error: {e}")
        return False
    except requests.exceptions.Timeout as e:
        print(f"❌ Timeout Error: {e}")
        return False
    except Exception as e:
        print(f"❌ Other Error: {e}")
        return False

def main():
    urls_to_test = [
        "http://localhost:8000",
        "http://127.0.0.1:8000",
        "http://192.168.1.230:8000"
    ]
    
    print("🚀 Backend Connectivity Test")
    print("=" * 50)
    
    working_urls = []
    
    for url in urls_to_test:
        print(f"\n📡 Testing: {url}")
        if test_connection(url):
            working_urls.append(url)
        print("-" * 30)
    
    print(f"\n📊 Results:")
    if working_urls:
        print(f"✅ Working URLs: {', '.join(working_urls)}")
        print(f"🎯 Recommended URL: {working_urls[0]}")
    else:
        print("❌ No working URLs found. Backend might be down.")

if __name__ == "__main__":
    main()