import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/login_page.dart'; // or your correct initial page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Wellness System',
      theme: ThemeData(
        textTheme: GoogleFonts.ralewayTextTheme(),
      ),
      home: const LoginPage(),
    );
  }
}