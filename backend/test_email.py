#!/usr/bin/env python3
"""
Test script to verify email OTP functionality
"""

import os
from dotenv import load_dotenv
import smtplib
from email.mime.text import MIMEText

# Load environment variables
load_dotenv()

def test_email_configuration():
    """Test if email configuration is working"""
    
    EMAIL_HOST = os.getenv("EMAIL_HOST")
    EMAIL_PORT = int(os.getenv("EMAIL_PORT", "587"))
    EMAIL_USER = os.getenv("EMAIL_USER")
    EMAIL_PASS = os.getenv("EMAIL_PASS")
    
    print("🔍 Testing email configuration...")
    print(f"EMAIL_HOST: {EMAIL_HOST}")
    print(f"EMAIL_PORT: {EMAIL_PORT}")
    print(f"EMAIL_USER: {EMAIL_USER}")
    print(f"EMAIL_PASS: {'*' * len(EMAIL_PASS) if EMAIL_PASS else 'NOT SET'}")
    
    if not EMAIL_USER or not EMAIL_PASS:
        print("❌ Email credentials not configured properly")
        return False
    
    try:
        # Test OTP
        test_otp = "123456"
        subject = "Test OTP - AI Wellness System"
        body = f"""
        Dear User,
        
        This is a test email for OTP functionality.
        Your test OTP is: {test_otp}
        
        If you received this email, the OTP system is working correctly!
        
        Best regards,
        AI Wellness System Team
        """
        
        msg = MIMEText(body)
        msg['Subject'] = subject
        msg['From'] = EMAIL_USER
        msg['To'] = EMAIL_USER  # Send to self for testing
        
        # Send email
        with smtplib.SMTP(EMAIL_HOST, EMAIL_PORT) as server:
            server.starttls()
            server.login(EMAIL_USER, EMAIL_PASS)
            server.send_message(msg)
        
        print("✅ Test email sent successfully!")
        print(f"📧 Test email sent to: {EMAIL_USER}")
        return True
        
    except Exception as e:
        print(f"❌ Failed to send test email: {str(e)}")
        return False

if __name__ == "__main__":
    test_email_configuration()