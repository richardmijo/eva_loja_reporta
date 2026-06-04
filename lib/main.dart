import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
import 'providers/incident_provider.dart';
import 'repositories/incident_repository.dart';
import 'router/app_router.dart';
import 'services/api_client.dart';
import 'services/api_service.dart';

void main() {
  final apiClient = ApiClient();
  final apiService = ApiService(apiClient);
  final incidentRepository = IncidentRepository(apiService);

  runApp(
    LojaReportApp(incidentRepository: incidentRepository),
  );
}

class LojaReportApp extends StatelessWidget {
  const LojaReportApp({super.key, required this.incidentRepository});

  final IncidentRepository incidentRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => IncidentProvider(incidentRepository),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp.router(
        title: 'LojaReport',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: createAppRouter(),
      ),
    );
  }
}
