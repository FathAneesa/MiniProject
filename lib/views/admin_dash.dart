import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_stud.dart';
import 'view_stud.dart';
import 'edit.dart';
// import 'delete.dart';
import 'login_page.dart'; // For Logout navigation
import 'view_week.dart'; // Import the new weekly academic summary page
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';

class AdminDash extends StatelessWidget {
  const AdminDash({super.key});

  void _logout(BuildContext context) {
    // Show logout confirmation dialog before navigating back
    ThemeHelpers.showThemedDialog(
      context: context,
      title: 'Logout Confirmation',
      content: 'Are you sure you want to logout?',
      cancelText: 'Cancel',
      confirmText: 'Logout',
      onConfirm: () {
        Navigator.of(context).pop(); // close dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemeHelpers.dashboardBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Admin header with themed avatar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    ThemeHelpers.themedAvatar(
                      size: 100,
                      icon: Icons.admin_panel_settings, // Admin icon
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome Admin',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // You can add your logo and welcome text here if you want
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ThemeHelpers.dashboardButton(
                          text: "Add Student",
                          backgroundColor: AppTheme.primaryColor,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddStud(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),

                        ThemeHelpers.dashboardButton(
                          text: "View Student Details",
                          backgroundColor: AppTheme.secondaryColor,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewStud(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),

                        ThemeHelpers.dashboardButton(
                          text: "Edit Student Details",
                          backgroundColor: AppTheme.secondaryVariant,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditPage()),
                            );
                          },
                        ),
                        // const SizedBox(height: 15),

                        // ThemeHelpers.dashboardButton(
                        //   text: "Delete Student",
                        //   backgroundColor: const Color.fromARGB(255, 184, 58, 158),
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => DeleteStudentPage()),
                        //     );
                        //   },
                        // ),
                        const SizedBox(height: 15),

                        ThemeHelpers.dashboardButton(
                          text: "Weekly Academic Summary",
                          backgroundColor: AppTheme.accentOrange,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewWeeklyAcademicSummary(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),

                        ThemeHelpers.dashboardButton(
                          text: "Logout",
                          backgroundColor: AppTheme.accentViolet,
                          onPressed: () {
                            _logout(context);
                          },
                        ),
                      ],
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
}