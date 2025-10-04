@echo off
echo Starting AI Wellness System...

echo.
echo [1/2] Starting Backend Server on port 8082...
start "Backend Server" cmd /k "cd /d "%~dp0" && python -m uvicorn backend.main:app --host 0.0.0.0 --port 8082 --reload"

timeout /t 5 /nobreak >nul

echo.
echo [2/2] Starting Flutter Web App on port 3002...
cd /d "%~dp0"
start "Flutter App" cmd /k "flutter run -d chrome --web-port 3002"

echo.
echo Setup complete! The application will be available at:
echo Backend API: http://localhost:8082
echo Frontend App: http://localhost:3002
echo.
pause