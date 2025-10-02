# MiniProject
## Ai based wellness and performance recommendation system 
### Abstract
In the modern educational landscape, maintaining student wellness and consistent academic performance has become increasingly challenging. Factors such as poor sleep, high stress levels, decreased focus, and low academic motivation often contribute to student burnout. To address these concerns, this project introduces an AI-Based Wellness and Performance Recommendation System designed specifically for students. The system utilizes mock data, simulating insights derived from smartphone usage to estimate wellness parameters such as sleep duration, mood fluctuations, focus levels, and stress indicators. Academic performance is monitored through the student's daily input of study hours, class focus scores, and marks secured in different subjects.The system integrates these wellness and academic indicators through a lightweight AI model to generate personalized suggestions aimed at improving both health and academic outcomes. Students receive actionable recommendations such as scheduling sleep, taking breaks, or increasing focus in class. A separate admin module facilitates the management of student records and configuration of AI logic for analysis. This approach not only empowers students to take charge of their mental and academic health but also helps administrators oversee system functionality and data quality.

## Running the Application

### Prerequisites
- Python 3.8+
- Flutter SDK
- MongoDB Atlas account (configured in .env)

### Quick Start
1. **Using Batch Script (Windows):**
   - Double-click `start_project.bat` to start both backend and frontend

2. **Using PowerShell Script:**
   - Right-click `start_project.ps1` and select "Run with PowerShell"

3. **Manual Start:**
   - Open terminal 1: Navigate to `backend` directory and run:
     ```
     python -m uvicorn backend.main:app --host 0.0.0.0 --port 8082 --reload
     ```
   - Open terminal 2: In project root, run:
     ```
     flutter run -d chrome --web-port 3002
     ```

### Login Credentials
- Admin User: username=`admin`, password=`Admin@123`

### Accessing the Application
- Backend API Documentation: http://localhost:8082/docs
- Frontend Web App: http://localhost:3002