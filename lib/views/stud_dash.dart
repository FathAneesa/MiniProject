import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_academic.dart';
import 'view_academic.dart';
import 'login_page.dart'; // ✅ Added for logout navigation
import 'memory_test.dart';
import 'rec.dart'; // Import the recommendations page
import 'weekrec.dart'; // Import the weekly progress page
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';


class StudDash extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const StudDash({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    // Extract student name and ID, with fallbacks for safety
    final String studentName = studentData['Student Name'] ?? "Student";
    final String studentId = studentData['UserID'] ?? "";

    return Scaffold(
      body: ThemeHelpers.dashboardBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                // Themed circular avatar with wellness icon
                // Available icon options:
                // Icons.psychology_outlined - Brain/mind (current)
                // Icons.favorite - Heart/health
                // Icons.spa - Wellness/relaxation
                // Icons.self_improvement - Personal growth
                // Icons.health_and_safety - Health focus
                // Icons.emoji_objects - Ideas/learning
                // Icons.fitness_center - Physical wellness
                ThemeHelpers.themedAvatar(
                  size: 120,
                  icon: Icons.psychology_outlined, // Brain/wellness icon
                ),
                const SizedBox(height: 20),
                Text(
                  "Welcome, $studentName", // Personalized welcome message
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                ThemeHelpers.dashboardButton(
                  text: "Add Academic Data",
                  backgroundColor: const Color.fromARGB(255, 215, 107, 186), // Soft rose pink for adding data
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAcademicPage(studentId: studentId),
                      ),
                    );
                    
                    // If academic data was updated, show notification
                    if (result == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ Academic data saved! Your recommendations will be updated.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: AppTheme.successColor,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 15),

                ThemeHelpers.dashboardButton(
                  text: "View Academic Data",
                  backgroundColor: const Color.fromARGB(255, 230, 140, 200), // Light pink for viewing
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAcademicPage(studentId: studentId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                ThemeHelpers.dashboardButton(
                  text: "Take Memory/Focus Test",
                  backgroundColor: const Color.fromARGB(255, 199, 76, 173), // Rich pink for testing
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MemoryTestPage(studentId: studentId)),
                    );
                  },
                ),
                const SizedBox(height: 15),

                ThemeHelpers.dashboardButton(
                  text: "View Daily Recommendation",
                  backgroundColor: const Color.fromARGB(255, 207, 89, 181), // Medium pink for recommendations
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecommendationPage(
                          studentId: studentId,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                ThemeHelpers.dashboardButton(
                  text: "View Weekly Progress",
                  backgroundColor: const Color.fromARGB(255, 184, 58, 158), // Deep pink for progress
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeeklyProgressPage(studentId: studentId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                ThemeHelpers.dashboardButton(
                  text: "Logout",
                  backgroundColor: const Color.fromARGB(255, 169, 45, 142), // Dark pink for logout
                  onPressed: () {
                    ThemeHelpers.showThemedDialog(
                      context: context,
                      title: "Logout",
                      content: "Are you sure you want to logout?",
                      cancelText: "Cancel",
                      confirmText: "Logout",
                      onConfirm: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
