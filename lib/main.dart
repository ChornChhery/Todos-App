// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'providers/submission_provider.dart';
import 'screens/input_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SubmissionProvider(),
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          // Define a clean color scheme
          primaryColor: const Color(0xFF42A5F5), // A soothing blue
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF42A5F5),
            primary: const Color(0xFF42A5F5),
            secondary: const Color(0xFFFFA726), // A warm orange for accents
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light gray for background

          // Use a professional font
          fontFamily: GoogleFonts.lato().fontFamily,

          // Style the AppBar
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF42A5F5),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),

          // Style buttons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42A5F5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
        home: const InputPage(),
      ),
    );
  }
}