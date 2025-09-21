import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import dotenv
import 'views/login_page.dart'; // or your correct initial page
import 'theme/app_theme.dart'; // Import the new theme

Future<void> main() async { // 2. Make main async
  await dotenv.load(fileName: ".env"); // 3. Load the .env file
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Wellness System',
      theme: AppTheme.lightTheme, // Use the global theme
      home: const LoginPage(),
    );
  }
}