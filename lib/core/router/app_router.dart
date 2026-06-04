import 'package:go_router/go_router.dart';
import 'package:eva_loja_reporta/models/incident.dart';
import 'package:eva_loja_reporta/screens/home_screen.dart';
import 'package:eva_loja_reporta/screens/detail_screen.dart';
import 'package:eva_loja_reporta/screens/about_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/detail',
      builder: (context, state) {
        final incident = state.extra as Incident;
        return DetailScreen(incident: incident);
      },
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
