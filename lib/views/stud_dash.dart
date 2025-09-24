import 'package:flutter/material.dart';
import 'add_academic.dart';
import 'view_academic.dart';
import 'login_page.dart';
import 'memory_test.dart';
import 'rec.dart';
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

              // Circular Grid of Student Features
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1,
                    ),
                    children: [
                      _buildCircleCard(
                        icon: Icons.add_chart,
                        text: "Add Academic Data",
                        color: const Color.fromARGB(255, 220, 220, 235),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddAcademicPage(studentId: studentId),
                            ),
                          );
                          if (result == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ Academic data saved! Your recommendations will be updated.',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                      _buildCircleCard(
                        icon: Icons.visibility,
                        text: "View Academic Data",
                        color: const Color.fromARGB(255, 210, 235, 230),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewAcademicPage(studentId: studentId),
                            ),
                          );
                        },
                      ),
                      _buildCircleCard(
                        icon: Icons.psychology,
                        text: "Memory/Focus Test",
                        color: const Color.fromARGB(255, 240, 225, 220),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemoryTestPage(studentId: studentId),
                            ),
                          );
                        },
                      ),
                      _buildCircleCard(
                        icon: Icons.recommend,
                        text: "Daily Recommendation",
                        color: const Color.fromARGB(255, 230, 220, 240),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecommendationPage(studentId: studentId),
                            ),
                          );
                        },
                      ),
                      _buildCircleCard(
                        icon: Icons.analytics_outlined,
                        text: "Weekly Progress",
                        color: const Color.fromARGB(255, 225, 235, 225),
                        onTap: () {
                          // TODO: Implement Weekly Progress page
                        },
                      ),
                      _buildCircleCard(
                        icon: Icons.logout,
                        text: "Logout",
                        color: const Color.fromARGB(255, 200, 200, 200),
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ),
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
