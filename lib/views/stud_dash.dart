import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_academic.dart';
import 'view_academic.dart';
import 'login_page.dart'; // ✅ Added for logout navigation
import 'memory_test.dart';


class StudDash extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const StudDash({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    // Extract student name and ID, with fallbacks for safety
    final String studentName = studentData['Student Name'] ?? "Student";
    final String studentId = studentData['UserID'] ?? "";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD6D6F7), Color(0xFFB8A6F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Image.asset('assets/logo.png', width: 60),
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome, $studentName", // Personalized welcome message
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            _buildButton(
              context,
              label: "Add Academic Data",
              color: const Color(0xFF6A5ACD),
              icon: Icons.add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAcademicPage(studentId: studentId),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            _buildButton(
  context,
  label: "View Academic Data",
  color: const Color(0xFF6A5ACD),
  icon: Icons.visibility, // 👁 better icon for view
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAcademicPage(studentId: studentId), // ✅ Correct
      ),
    );
  },
),

            const SizedBox(height: 16),

            _buildButton(
              context,
              label: "Take Memory/Focus Test",
              color: const Color(0xFF28C78E),
              icon: Icons.psychology,
              onTap: () {
                Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => MemoryTestPage(studentId: studentId)),
);

              },
            ),
            const SizedBox(height: 16),

            _buildButton(
              context,
              label: "View Daily Recommendation",
              color: const Color(0xFF9370DB),
              icon: Icons.star,
              onTap: () {
              },
            ),
            const SizedBox(height: 16),

            _buildButton(
              context,
              label: "View Weekly Progress",
              color: const Color(0xFFF06292),
              icon: Icons.bar_chart,
              onTap: () {
              },
            ),
            const SizedBox(height: 16),

            _buildButton(
              context,
              label: "Logout",
              color: const Color(0xFFE57373),
              icon: Icons.logout,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text("Logout"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
