import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/incident.dart';
import '../screens/about_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final incident = state.extra as Incident?;
          if (incident == null) {
            return const Scaffold(
              body: Center(child: Text('Incident not found')),
            );
          }
          return DetailScreen(incident: incident);
        },
      ),
    ],
  );
}
