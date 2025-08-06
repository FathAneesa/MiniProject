import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudDash extends StatelessWidget {
  const StudDash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor is not needed since gradient is set in Container
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
            // Logo Circle
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Image.asset(
                'assets/logo.png', // Replace with your logo path
                width: 60,
              ),
            ),
            const SizedBox(height: 20),

            // Welcome Text
            Text(
              "Welcome, Student's Name",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Buttons
            _buildButton(
              context,
              label: "Add Academic Data",
              color: const Color(0xFF6A5ACD),
              icon: Icons.add,
            ),
            const SizedBox(height: 16),

            _buildButton(
              context,
              label: "Take Memory/Focus Test",
              color: const Color(0xFF28C78E),
              icon: Icons.psychology,
            ),
            const SizedBox(height: 16),

            _buildButton(
              context,
              label: "View Daily Recommendation",
              color: const Color(0xFF9370DB),
              icon: Icons.star,
            ),
            const SizedBox(height: 16),

            _buildButton(
              context,
              label: "View Weekly Progress",
              color: const Color(0xFFF06292),
              icon: Icons.bar_chart,
            ),
            const SizedBox(height: 16),

            _buildButton(
              context,
              label: "Logout",
              color: const Color(0xFFE57373),
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label, required Color color, required IconData icon}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Add navigation
        },
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
