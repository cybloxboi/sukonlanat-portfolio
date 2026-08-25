import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sukonlanat_portfolio/pages/home_page.dart';
import 'package:sukonlanat_portfolio/pages/certificate_view_page.dart';
import 'package:sukonlanat_portfolio/pages/section_page.dart';
import 'package:sukonlanat_portfolio/services/university_data_controller.dart';
// import 'package:sukonlanat_portfolio/widgets/audio_player_widget.dart';
import 'package:sukonlanat_portfolio/widgets/background_video.dart';
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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    universityDataController.loadFromUri();
  }

  static CustomTransitionPage<void> _transitionPage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final pageAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final previousPageAnimation = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
          reverseCurve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(
            begin: 1,
            end: 0,
          ).animate(previousPageAnimation),
          child: FadeTransition(
            opacity: pageAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(pageAnimation),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.985,
                  end: 1,
                ).animate(pageAnimation),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  static final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _transitionPage(
          state,
          HomePage(universityId: state.uri.queryParameters['id']),
        ),
      ),
      GoRoute(
        path: '/certificates',
        pageBuilder: (context, state) => _transitionPage(
          state,
          SectionPage(
            title: 'Certificates',
            description: 'Certificates page',
            selectedCertificate: state.uri.queryParameters['certificate'],
          ),
        ),
      ),
      GoRoute(
        path: '/certificates/:certificateId',
        pageBuilder: (context, state) => _transitionPage(
          state,
          CertificateViewPage.fromId(
            certificateId: state.pathParameters['certificateId'] ?? '',
            returnPath: state.uri.queryParameters['from'] == 'home'
                ? '/'
                : '/certificates',
          ),
        ),
      ),
      GoRoute(
        path: '/projects',
        pageBuilder: (context, state) => _transitionPage(
          state,
          const SectionPage(title: 'Projects', description: 'Projects page'),
        ),
      ),
      GoRoute(
        path: '/activities',
        pageBuilder: (context, state) => _transitionPage(
          state,
          const SectionPage(
            title: 'Activities',
            description: 'Activities page',
          ),
        ),
      ),
      GoRoute(
        path: '/about_me',
        pageBuilder: (context, state) => _transitionPage(
          state,
          const SectionPage(title: 'About Me', description: 'About Me page'),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            BackgroundVideo(child: child ?? const SizedBox.shrink()),
            // const AudioPlayerWidget(),
          ],
        );
      },
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
