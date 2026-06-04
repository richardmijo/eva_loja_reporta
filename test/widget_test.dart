import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:eva_loja_reporta/main.dart';
import 'package:eva_loja_reporta/models/incident.dart';
import 'package:eva_loja_reporta/providers/favorites_provider.dart';
import 'package:eva_loja_reporta/providers/incident_provider.dart';
import 'package:eva_loja_reporta/repositories/incident_repository.dart';
import 'package:eva_loja_reporta/services/api_client.dart';
import 'package:eva_loja_reporta/services/api_service.dart';

class FakeIncidentRepository extends IncidentRepository {
  FakeIncidentRepository() : super(ApiService(ApiClient()));

  @override
  Future<List<Incident>> getIncidents() async => [];
}

void main() {
  testWidgets('App shows LojaReport title', (WidgetTester tester) async {
    final repository = FakeIncidentRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => IncidentProvider(repository),
          ),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ],
        child: LojaReportApp(incidentRepository: repository),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('LojaReport'), findsOneWidget);
  });
}
