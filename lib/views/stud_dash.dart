import 'package:flutter/material.dart';
import 'add_academic.dart';
import 'view_academic.dart';
import 'login_page.dart';
import 'memory_test.dart';
import 'rec.dart'; // Import the recommendations page
import 'weekrec.dart'; // Import the weekly progress page
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';

class StudDash extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const StudDash({super.key, required this.studentData});

  void _logout(BuildContext context) {
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
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String studentName = studentData['Student Name'] ?? "Student";
    final String studentId = studentData['UserID'] ?? "";

    return Scaffold(
      body: ThemeHelpers.dashboardBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Student Avatar
              ThemeHelpers.themedAvatar(
                size: 100,
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 16),

              // Welcome Text
              Text(
                "Welcome, $studentName",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
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
    );
  }

  // 🔹 Helper method for circular animated cards
  Widget _buildCircleCard({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        double scale = 1.0;

        return GestureDetector(
          onTapDown: (_) => setState(() => scale = 0.95),
          onTapUp: (_) {
            setState(() => scale = 1.0);
            onTap();
          },
          onTapCancel: () => setState(() => scale = 1.0),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 40, color: Colors.black87),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
