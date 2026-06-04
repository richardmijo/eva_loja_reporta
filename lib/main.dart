import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/about_screen.dart';
import 'models/incident.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final incident = state.extra as Incident;
          return DetailScreen(incidentArg: incident);
        },
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LojaReport',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF3B82F6),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      routerConfig: _router,
    );
  }
}
