# Email Setup Guide for OTP Functionality

## Quick Setup Steps

### 1. Gmail Setup (Recommended)
1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate App Password**:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Select "Mail" and your device
   - Copy the 16-character password

### 2. Update .env File
```env
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
EMAIL_ADDRESS=your-email@gmail.com
EMAIL_PASSWORD=your-16-character-app-password
```

### 3. Alternative Email Providers

#### Outlook/Hotmail
```env
SMTP_SERVER=smtp-mail.outlook.com
SMTP_PORT=587
EMAIL_ADDRESS=your-email@outlook.com
EMAIL_PASSWORD=your-password
```

#### Yahoo Mail
```env
SMTP_SERVER=smtp.mail.yahoo.com
SMTP_PORT=587
EMAIL_ADDRESS=your-email@yahoo.com
EMAIL_PASSWORD=your-app-password
```

### 4. Testing
- Run your backend: `python main.py` or `uvicorn main:app --reload`
- Try the forgot password flow
- Check console for debug messages if email fails

### 5. Production Notes
- Remove `debug_otp` from responses in production
- Set up proper email templates
- Consider using dedicated email services like SendGrid, AWS SES, or Mailgun

### 6. Troubleshooting
- **"Authentication failed"**: Check app password, not regular password
- **"Connection refused"**: Check SMTP server and port
- **"Email not sent"**: Verify email credentials and internet connection
- **OTP in console**: Email service unavailable, but OTP still generated for testing