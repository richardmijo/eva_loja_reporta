import 'package:go_router/go_router.dart';
import '../models/incidente.dart';
import '../screens/home_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/about_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/detail',
      builder: (context, state) {
        final incidente = state.extra as Incidente;
        return DetailScreen(incidente: incidente);
      },
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
