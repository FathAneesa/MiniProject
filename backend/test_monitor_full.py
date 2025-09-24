import asyncio
import aiohttp
import json

async def test_monitor_endpoint():
    """Test the actual monitor endpoint to see what it returns"""
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get('http://localhost:8000/monitor') as response:
                if response.status == 200:
                    data = await response.json()
                    print("Monitor endpoint response:")
                    print(json.dumps(data, indent=2))
                    
                    print("\nDetailed breakdown of last_logins:")
                    for i, login in enumerate(data.get('last_logins', []), 1):
                        print(f"{i:2d}. Username: {login.get('username', 'N/A'):10} | "
                              f"Role: {login.get('role', 'N/A'):6} | "
                              f"Time: {login.get('time', 'N/A')} | "
                              f"Name: {login.get('studentName', 'N/A')}")
                else:
                    print(f"Error: HTTP {response.status}")
                    text = await response.text()
                    print(text)
    except Exception as e:
        print(f"Exception: {e}")

if __name__ == "__main__":
    asyncio.run(test_monitor_endpoint())