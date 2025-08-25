import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_stud.dart';
import 'store_stud.dart';
import 'login_page.dart'; // For Logout navigation

class AdminDash extends StatelessWidget {
  const AdminDash({super.key});

  void _logout(BuildContext context) {
    // Show logout confirmation dialog before navigating back
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Logout Confirmation', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[700])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildDashboardButton({
    required Color color,
    required String text,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.pinkAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // You can add your logo and welcome text here if you want

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDashboardButton(
                          color: Colors.blue.shade700,
                          text: "Add Student",
                          context: context,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStud()));
                          },
                        ),
                        const SizedBox(height: 15),

                        buildDashboardButton(
                          color: Colors.orange.shade700,
                          text: "View Student Details",
                          context: context,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreStud()));
                          },
                        ),
                        const SizedBox(height: 15),

                        buildDashboardButton(
                          color: Colors.teal.shade700,
                          text: "Take Memory Focus Test",
                          context: context,
                          onTap: () {
                            // TODO: Navigate to Memory Focus Test page
                          },
                        ),
                        const SizedBox(height: 15),

                        buildDashboardButton(
                          color: Colors.indigo.shade700,
                          text: "View Daily Recommendation",
                          context: context,
                          onTap: () {
                            // TODO: Navigate to Daily Recommendation page
                          },
                        ),
                        const SizedBox(height: 15),

                        buildDashboardButton(
                          color: Colors.purple.shade700,
                          text: "View Weekly Progress",
                          context: context,
                          onTap: () {
                            // TODO: Navigate to Weekly Progress page
                          },
                        ),
                        const SizedBox(height: 15),

                        buildDashboardButton(
                          color: Colors.red.shade700,
                          text: "Logout",
                          context: context,
                          onTap: () {
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