import 'package:flutter_test/flutter_test.dart';
import 'package:eva_loja_reporta/main.dart';
import 'package:eva_loja_reporta/controllers/incident_controller.dart';
import 'package:eva_loja_reporta/repositories/incident_repository.dart';
import 'package:eva_loja_reporta/models/incident.dart';

class MockIncidentRepository extends IncidentRepository {
  @override
  Future<List<Incident>> fetchIncidents() async {
    return [
      Incident(
        id: '1',
        title: 'Mock Title Pothole',
        description: 'Mock Description',
        type: 'pothole',
        status: 'pending',
        zone: 'Centro',
      ),
    ];
  }
}

void main() {
  setUp(() {
    IncidentController().repository = MockIncidentRepository();
  });

  testWidgets('App title smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump(); // Allow state changes/loading to resolve

    // Verify that our app bar title is LojaReport.
    expect(find.text('LojaReport'), findsOneWidget);
  });
}
