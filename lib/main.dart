import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sukonlanat_portfolio/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            HomePage(universityId: state.uri.queryParameters['id']),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 240, 170, 170),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 170, 170),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontFamilyFallback: [GoogleFonts.googleSans().fontFamily!],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 240, 170, 170),
          brightness: Brightness.dark,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.black),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(iconColor: WidgetStatePropertyAll(Colors.black)),
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontFamilyFallback: [GoogleFonts.googleSans().fontFamily!],
      ),
      themeMode: ThemeMode.system,
    );
  }
}
