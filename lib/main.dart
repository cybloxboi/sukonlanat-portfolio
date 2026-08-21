import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sukonlanat_portfolio/pages/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 250, 194, 255),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontFamilyFallback: [GoogleFonts.googleSans().fontFamily!],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.dark,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontFamilyFallback: [GoogleFonts.googleSans().fontFamily!],
      ),
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}
