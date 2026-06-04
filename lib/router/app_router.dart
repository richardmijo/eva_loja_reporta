import 'package:go_router/go_router.dart';

import '../models/incident.dart';
import '../screens/about_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  static const home = '/';
  static const detail = '/detail';
  static const about = '/about';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.detail,
        builder: (context, state) {
          final incident = state.extra as Incident;
          return DetailScreen(incident: incident);
        },
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
