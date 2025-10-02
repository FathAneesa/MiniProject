#!/bin/bash
# Simple script to run the project

echo "Starting AI Wellness System..."

# Start backend in background
echo "Starting Backend Server on port 8082..."
cd backend
python -m uvicorn backend.main:app --host 0.0.0.0 --port 8082 --reload &

# Wait a bit for backend to start
sleep 5

# Start frontend
echo "Starting Flutter Web App on port 3002..."
cd ..
flutter run -d chrome --web-port 3002