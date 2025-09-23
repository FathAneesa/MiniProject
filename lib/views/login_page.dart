// /lib/views/login_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // For TimeoutException
import 'admin_dash.dart';
import 'stud_dash.dart';
import 'forgot.dart';
import '../config.dart'; // Import the centralized config
import '../theme/app_theme.dart'; // Import theme
import '../theme/theme_helpers.dart'; // Import theme helpers


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'Please enter username and password',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$apiBaseUrl/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == 'success') {
          ThemeHelpers.showThemedSnackBar(
            context,
            message: 'Login successful!',
            backgroundColor: AppTheme.successColor,
          );

          // (MODIFIED) Check if 'role' key exists and is 'admin'.
          // If not, assume it's a student.
          if (data.containsKey('role') && data['role'] == 'admin') {
            // This is an Admin user.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDash()),
            );
          } else {
            // This is a Student user (since 'role' field is absent for them).
            final studentData = data['user_data'];
            if (studentData != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StudDash(studentData: studentData),
                ),
              );
            } else {
              ThemeHelpers.showThemedSnackBar(
                context,
                message: 'Could not retrieve student details.',
                isError: true,
              );
            }
          }
        } else {
          ThemeHelpers.showThemedSnackBar(
            context,
            message: data['message'] ?? 'Login failed',
            isError: true,
          );
        }
      } else {
        // Handle backend error responses (like 401 Unauthorized).
        ThemeHelpers.showThemedSnackBar(
          context,
          message: data['detail'] ?? 'Error during login',
          isError: true,
        );
      }
    } on http.ClientException {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'Cannot connect to server. Is it running?',
        isError: true,
      );
    } on TimeoutException {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'Connection timed out. Please check your network.',
        isError: true,
      );
    } catch (e) {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: 'An unexpected error occurred: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ThemeHelpers.gradientBackground(
            child: const SizedBox.expand(),
          ),
          Center(
            child: SingleChildScrollView(
              child: ThemeHelpers.themedCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ThemeHelpers.themedAvatar(
                      size: 100,
                      icon: Icons.account_circle_outlined, // User/login icon
                    ),
                    const SizedBox(height: 16),
                    ThemedWidgets.appTitle(),
                    const SizedBox(height: 24),
                    ThemeHelpers.themedTextField(
                      controller: usernameController,
                      labelText: 'Username',
                    ),
                    const SizedBox(height: 16),
                    ThemeHelpers.themedTextField(
                      controller: passwordController,
                      labelText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ThemeHelpers.themedButton(
                      text: 'Login',
                      onPressed: isLoading ? () {} : login,
                      style: isLoading ? 
                        AppButtonStyles.primaryButton.copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            AppTheme.primaryColor.withOpacity(0.6)
                          ),
                        ) : AppButtonStyles.primaryButton,
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 16),
                      ThemedWidgets.loadingIndicator(message: 'Logging in...'),
                    ],
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password? Click here.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}