import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'providers/home_provider.dart';
import 'repositories/incident_repository.dart';
import 'router/app_router.dart';

void main() {
  final dioClient = DioClient();
  final repository = IncidentRepository(dioClient);

  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeProvider(repository),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LojaReport',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: createRouter(),
    );
  }
}
