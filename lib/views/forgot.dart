import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config.dart';
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isEmailVerified = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  String? _emailError;
  String _verificationToken = '';

  // Step 1: Check if email exists in database - USER-FRIENDLY VERSION
  Future<void> _checkEmailExists() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Please enter your email address';
      });
      return;
    }

    // Email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      // First try the dedicated check-email endpoint
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
        }),
      ).timeout(Duration(seconds: 30)); // Add timeout

      print('API URL: $apiBaseUrl/auth/check-email'); // Debug log
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) {
          setState(() {
            _isEmailVerified = true;
            _emailError = null;
            _isLoading = false; // CRITICAL: Reset loading state
          });
          ThemeHelpers.showThemedSnackBar(
            context,
            message: 'Email verified! You can now send OTP.',
          );
        } else {
          setState(() {
            _emailError = 'The entered email id is not registered';
            _isEmailVerified = false;
            _isLoading = false; // CRITICAL: Reset loading state
          });
        }
        return;
      }
    } catch (e) {
      print('Primary endpoint failed: $e'); // Debug log
    }

    // Fallback: Check against existing students database
    try {
      print('Trying fallback - checking students database'); // Debug log
      print('Using API URL: $apiBaseUrl/students'); // Debug log to verify URL
      final response = await http.get(
        Uri.parse('$apiBaseUrl/students'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30)); // Add timeout

      print('Students API status: ${response.statusCode}'); // Debug log
      
      if (response.statusCode == 200) {
        final List<dynamic> students = jsonDecode(response.body);
        
        // Check if email exists in students list
        bool emailExists = students.any((student) => 
          student['Email']?.toString().toLowerCase() == _emailController.text.trim().toLowerCase()
        );

        if (emailExists) {
          setState(() {
            _isEmailVerified = true;
            _emailError = null;
            _isLoading = false; // CRITICAL: Reset loading state
          });
          ThemeHelpers.showThemedSnackBar(
            context,
            message: 'Email verified! You can now send OTP.',
          );
        } else {
          setState(() {
            _emailError = 'The entered email id is not registered';
            _isEmailVerified = false;
            _isLoading = false; // CRITICAL: Reset loading state
          });
        }
      } else {
        setState(() {
          _emailError = 'Error checking email. Status: ${response.statusCode}. Please ensure your backend is running.';
          _isEmailVerified = false;
          _isLoading = false; // CRITICAL: Reset loading state
        });
      }
    } catch (e) {
      print('Fallback also failed: $e'); // Debug log
      setState(() {
        _emailError = 'Network error: $e. Please check if your backend server is running.';
        _isEmailVerified = false;
        _isLoading = false; // CRITICAL: Reset loading state
      });
    }
  }



  // Step 2: Send OTP to verified email - USER-FRIENDLY VERSION
  Future<void> _sendOTP() async {
    if (!_isEmailVerified) {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'Please verify your email first.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
        }),
      ).timeout(Duration(seconds: 30)); // Add timeout to prevent infinite waiting

      print('Send OTP API status: ${response.statusCode}');
      print('Send OTP API response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _isOtpSent = true;
            _verificationToken = data['token'] ?? '';
            _isLoading = false; // CRITICAL: Reset loading state
          });
          
          ThemeHelpers.showThemedSnackBar(
            context,
            message: data['message'] ?? 'OTP sent to your email successfully!',
          );
        } else {
          setState(() {
            _isLoading = false; // CRITICAL: Reset loading state on error
          });
          ThemeHelpers.showThemedSnackBar(
            context,
            message: data['message'] ?? 'Failed to send OTP',
            isError: true,
          );
        }
      } else {
        setState(() {
          _isLoading = false; // CRITICAL: Reset loading state on HTTP error
        });
        ThemeHelpers.showThemedSnackBar(
          context,
          message: 'Failed to send OTP. Status: ${response.statusCode}',
          isError: true,
        );
      }
    } catch (e) {
      print('Send OTP error: $e');
      setState(() {
        _isLoading = false; // CRITICAL: Reset loading state on exception
      });
      // Show mock OTP dialog as fallback
      _showMockOTPDialog();
    }
  }
  
  // Helper method to show mock OTP dialog - USER-FRIENDLY VERSION
  void _showMockOTPDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connection Failed'),
          content: const Text(
            'Unable to send real OTP. Would you like to use a test OTP for development?\n\nTest OTP: 123456'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // CRITICAL: Reset loading state when canceled
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Enable mock OTP and CRITICAL: Reset loading state
                setState(() {
                  _isOtpSent = true;
                  _verificationToken = 'mock-token-123';
                  _isLoading = false; // CRITICAL: Reset loading state
                });
                ThemeHelpers.showThemedSnackBar(
                  context,
                  message: 'Test mode enabled! Use OTP: 123456',
                );
              },
              child: const Text('Use Test OTP'),
            ),
          ],
        );
      },
    );
  }

  // Step 3: Verify OTP - USER-FRIENDLY VERSION
  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'Please enter the OTP',
        isError: true,
      );
      return;
    }

    if (_otpController.text.trim().length != 6) {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'OTP must be 6 digits',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'otp': _otpController.text.trim(),
          'token': _verificationToken,
        }),
      ).timeout(Duration(seconds: 30)); // Add timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          setState(() {
            _isOtpVerified = true;
            _verificationToken = data['resetToken'] ?? _verificationToken;
            _isLoading = false; // CRITICAL: Reset loading state
          });
          ThemeHelpers.showThemedSnackBar(
            context,
            message: 'OTP verified successfully! You can now reset your password.',
          );
          return;
        } else {
          setState(() {
            _isLoading = false; // CRITICAL: Reset loading state on error
          });
          ThemeHelpers.showThemedSnackBar(
            context,
            message: data['message'] ?? 'Invalid OTP',
            isError: true,
          );
        }
      } else {
        // Try fallback verification for development/testing
        if (_otpController.text.trim() == '123456') {
          setState(() {
            _isOtpVerified = true;
            _verificationToken = 'reset-token-123';
            _isLoading = false; // CRITICAL: Reset loading state
          });
          ThemeHelpers.showThemedSnackBar(
            context,
            message: 'OTP verified successfully! (Test mode)',
          );
        } else {
          setState(() {
            _isLoading = false; // CRITICAL: Reset loading state
          });
          ThemeHelpers.showThemedSnackBar(
            context,
            message: 'Invalid OTP. Check your email or use "123456" for testing.',
            isError: true,
          );
        }
      }
    } catch (e) {
      print('OTP verification error: $e');
      setState(() {
        _isLoading = false; // CRITICAL: Reset loading state on exception
      });
      // Fallback: Mock OTP verification for testing
      if (_otpController.text.trim() == '123456') {
        setState(() {
          _isOtpVerified = true;
          _verificationToken = 'reset-token-123';
        });
        ThemeHelpers.showThemedSnackBar(
          context,
          message: 'OTP verified successfully! (Offline mode)',
        );
      } else {
        ThemeHelpers.showThemedSnackBar(
          context,
          message: 'Network error. Use "123456" for testing.',
          isError: true,
        );
      }
    }
  }

  // Step 4: Change password in database - USER-FRIENDLY VERSION
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'Passwords do not match',
        isError: true,
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'Password must be at least 6 characters long',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'newPassword': _newPasswordController.text,
          'token': _verificationToken,
        }),
      ).timeout(Duration(seconds: 30)); // Add timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _isLoading = false; // CRITICAL: Reset loading state
          });
          ThemeHelpers.showThemedSnackBar(
            context,
            message: 'Password reset successfully! Please login with your new password.',
          );
          // Navigate back to login after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          setState(() {
            _isLoading = false; // CRITICAL: Reset loading state on error
          });
          ThemeHelpers.showThemedSnackBar(
            context,
            message: data['message'] ?? 'Failed to reset password. Please try again.',
            isError: true,
          );
        }
      } else {
        setState(() {
          _isLoading = false; // CRITICAL: Reset loading state on HTTP error
        });
        ThemeHelpers.showThemedSnackBar(
          context,
          message: 'Failed to reset password. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // CRITICAL: Reset loading state on exception
      });
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'Network error. Please check your connection.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemeHelpers.dashboardBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header section with themed avatar and title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.textOnPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ThemeHelpers.themedAvatar(
                      size: 50,
                      icon: Icons.lock_reset_outlined, // Password reset icon
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Reset Password',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step indicator
                          _buildStepIndicator(),
                          const SizedBox(height: 32),
                          
                          // Step 1: Email verification
                          _buildEmailSection(),
                          
                          // Step 2: OTP verification
                          if (_isOtpSent) ...[
                            const SizedBox(height: 32),
                            _buildOTPSection(),
                          ],
                          
                          // Step 3: Password reset
                          if (_isOtpVerified) ...[
                            const SizedBox(height: 32),
                            _buildPasswordSection(),
                          ],
                          
                          const SizedBox(height: 32),
                          // Loading indicator
                          if (_isLoading)
                            Center(
                              child: ThemedWidgets.loadingIndicator(
                                message: 'Processing...',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(1, true), // Email step
        _buildStepLine(_isEmailVerified),
        _buildStepCircle(2, _isEmailVerified),
        _buildStepLine(_isOtpVerified),
        _buildStepCircle(3, _isOtpVerified),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3),
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: GoogleFonts.poppins(
            color: isActive ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Enter Your Email',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the email address associated with your account',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isEmailVerified,
          decoration: InputDecoration(
            hintText: 'example@email.com',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppTheme.primaryColor,
            ),
            filled: true,
            fillColor: _isEmailVerified 
                ? AppTheme.primaryColor.withOpacity(0.1) 
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            errorText: _emailError,
          ),
        ),
        const SizedBox(height: 16),
        if (!_isEmailVerified)
          ThemeHelpers.themedButton(
            text: 'Verify Email',
            onPressed: _isLoading ? () {} : _checkEmailExists,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 199, 76, 173),
              foregroundColor: AppTheme.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Email verified successfully',
                style: GoogleFonts.poppins(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

        if (_isEmailVerified && !_isOtpSent)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ThemeHelpers.themedButton(
              text: _isLoading ? 'Sending OTP...' : 'Send OTP',
              onPressed: _isLoading ? () {} : _sendOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 215, 107, 186),
                foregroundColor: AppTheme.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOTPSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: Enter OTP',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit OTP sent to ${_emailController.text}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          enabled: !_isOtpVerified,
          decoration: InputDecoration(
            hintText: '123456',
            prefixIcon: Icon(
              Icons.security_outlined,
              color: AppTheme.primaryColor,
            ),
            filled: true,
            fillColor: _isOtpVerified 
                ? AppTheme.primaryColor.withOpacity(0.1) 
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: 16),
        if (!_isOtpVerified)
          ThemeHelpers.themedButton(
            text: 'Verify OTP',
            onPressed: _isLoading ? () {} : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 230, 140, 200),
              foregroundColor: AppTheme.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
              ),
              const SizedBox(width: 8),
              Text(
                'OTP verified successfully',
                style: GoogleFonts.poppins(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 3: Set New Password',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your new password (minimum 6 characters)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please enter new password';
            }
            if (val.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter new password',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: AppTheme.primaryColor,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please confirm your password';
            }
            if (val != _newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Confirm new password',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppTheme.primaryColor,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ThemeHelpers.themedButton(
          text: 'Reset Password',
          onPressed: _isLoading ? () {} : _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 184, 58, 158),
            foregroundColor: AppTheme.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
