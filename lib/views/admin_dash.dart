import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_stud.dart';
import 'view_stud.dart';
import 'edit.dart';
import 'login_page.dart'; // For Logout navigation
import '../theme/theme_helpers.dart';

class AdminDash extends StatelessWidget {
  const AdminDash({super.key});

  void _logout(BuildContext context) {
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
      body: Container(
        color: const Color.fromARGB(255, 240, 241, 153),
        child: SafeArea(
          child: Column(
            children: [
              // Admin header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    ThemeHelpers.themedAvatar(
                      size: 100,
                      icon: Icons.admin_panel_settings,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome Admin',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 210, 206, 206),
                          ),
                    ),
                  ],
                ),
              ),

              // Grid of circular cards
              Expanded(
                child: Padding(
<<<<<<< HEAD
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1, // square cells
                    children: [
                      GridCard(
                        icon: Icons.person_add,
                        text: "Add Student",
                        color: const Color.fromARGB(255, 223, 217, 222),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddStud()),
                          );
                        },
                      ),
                      GridCard(
                        icon: Icons.list_alt,
                        text: "View Student Details",
                        color: const Color.fromARGB(255, 225, 219, 219),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ViewStud()),
                          );
                        },
                      ),
                      GridCard(
                        icon: Icons.edit,
                        text: "Edit Student Details",
                        color: const Color.fromARGB(255, 232, 228, 231),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditPage()),
                          );
                        },
                      ),
                      GridCard(
                        icon: Icons.analytics,
                        text: "View Weekly Analysis",
                        color: const Color.fromARGB(255, 242, 233, 240),
                        onTap: () {
                          // TODO: Navigate to Weekly Progress page
                        },
                      ),
                      GridCard(
                        icon: Icons.logout,
                        text: "Logout",
                        color: const Color.fromARGB(255, 223, 215, 221),
                        onTap: () => _logout(context),
                      ),
                    ],
=======
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ThemeHelpers.dashboardButton(
                          text: "Add Student",
                          backgroundColor: const Color.fromARGB(255, 199, 76, 173),
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
                          backgroundColor: const Color.fromARGB(255, 215, 107, 186),
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
                          backgroundColor: const Color.fromARGB(255, 230, 140, 200),
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
                          text: "View Weekly Analysis",
                          backgroundColor: const Color.fromARGB(255, 207, 89, 181),
                          onPressed: () {
                            // TODO: Navigate to Weekly Progress page
                          },
                        ),
                        const SizedBox(height: 15),

                        ThemeHelpers.dashboardButton(
                          text: "Logout",
                          backgroundColor: const Color.fromARGB(255, 169, 45, 142),
                          onPressed: () {
                            _logout(context);
                          },
                        ),
                      ],
                    ),
>>>>>>> dcaafeaf03bd3d510c77338faab07230428e1989
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

// -----------------------------
// GridCard Widget with tap animation
// -----------------------------
class GridCard extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const GridCard({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  State<GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<GridCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95); // scale down
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0); // scale back
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0); // reset if cancelled
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 40, color: Colors.black87),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

