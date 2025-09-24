#!/usr/bin/env python3
"""
Test script to analyze student data and sorting behavior
"""

import requests
import json
from datetime import datetime

def analyze_student_data():
    """Analyze student data structure and sorting"""
    try:
        # Fetch student data
        response = requests.get("http://localhost:8000/students", timeout=10)
        
        if response.status_code == 200:
            students = response.json()
            print(f"Total students: {len(students)}")
            
            # Display first few students with their IDs and creation info
            print("\nStudent Data Analysis:")
            print("=" * 80)
            
            for i, student in enumerate(students[:10]):  # First 10 students
                student_id = student.get('_id', 'N/A')
                student_name = student.get('Student Name', 'N/A')
                admission_no = student.get('Admission No', 'N/A')
                user_id = student.get('UserID', 'N/A')
                
                # Extract ObjectId timestamp if possible
                oid_timestamp = "N/A"
                if isinstance(student_id, dict) and '$oid' in student_id:
                    oid = student_id['$oid']
                    oid_timestamp = extract_timestamp_from_objectid(oid)
                elif isinstance(student_id, str):
                    oid_timestamp = extract_timestamp_from_objectid(student_id)
                
                print(f"{i+1:2d}. Name: {student_name:<20} | Admission: {admission_no:<10} | UserID: {user_id:<8} | OID: {oid_timestamp}")
                
            # Test sorting methods
            print("\n\nSorting Analysis:")
            print("=" * 50)
            
            # Test ObjectId sorting
            print("\n1. Sorting by ObjectId (descending):")
            sorted_by_oid = sort_students_by_objectid(students, descending=True)
            for i, student in enumerate(sorted_by_oid[:5]):
                student_name = student.get('Student Name', 'N/A')
                student_id = student.get('_id', 'N/A')
                oid = student_id.get('$oid', student_id) if isinstance(student_id, dict) else student_id
                oid_timestamp = extract_timestamp_from_objectid(oid) if isinstance(oid, str) else "N/A"
                print(f"   {i+1}. {student_name} ({oid_timestamp})")
                
            # Test Admission Number sorting
            print("\n2. Sorting by Admission Number (descending):")
            sorted_by_admission = sort_students_by_admission(students, descending=True)
            for i, student in enumerate(sorted_by_admission[:5]):
                student_name = student.get('Student Name', 'N/A')
                admission_no = student.get('Admission No', 'N/A')
                print(f"   {i+1}. {student_name} (Admission: {admission_no})")
                
        else:
            print(f"Error fetching students: {response.status_code}")
            
    except Exception as e:
        print(f"Error: {e}")

def extract_timestamp_from_objectid(oid):
    """Extract timestamp from MongoDB ObjectId"""
    try:
        if len(oid) >= 8:
            # First 4 bytes of ObjectId are timestamp
            timestamp_hex = oid[:8]
            timestamp = int(timestamp_hex, 16)
            dt = datetime.fromtimestamp(timestamp)
            return dt.strftime("%Y-%m-%d %H:%M")
        return "Invalid OID"
    except:
        return "Parse Error"

def sort_students_by_objectid(students, descending=True):
    """Sort students by ObjectId timestamp"""
    def get_oid_timestamp(student):
        student_id = student.get('_id', '')
        if isinstance(student_id, dict) and '$oid' in student_id:
            oid = student_id['$oid']
        elif isinstance(student_id, str):
            oid = student_id
        else:
            return 0
            
        try:
            if len(oid) >= 8:
                timestamp_hex = oid[:8]
                return int(timestamp_hex, 16)
            return 0
        except:
            return 0
    
    return sorted(students, key=get_oid_timestamp, reverse=descending)

def sort_students_by_admission(students, descending=True):
    """Sort students by Admission Number"""
    def get_admission_number(student):
        admission = str(student.get('Admission No', '0'))
        # Try to extract numeric part for better sorting
        try:
            # Extract all digits and use the largest number found
            import re
            numbers = re.findall(r'\d+', admission)
            if numbers:
                return max(int(num) for num in numbers)
            return 0
        except:
            return 0
    
    return sorted(students, key=get_admission_number, reverse=descending)

if __name__ == "__main__":
    analyze_student_data()