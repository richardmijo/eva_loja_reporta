import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:eva_loja_reporta/core/network/dio_client.dart';
import 'package:eva_loja_reporta/main.dart';
import 'package:eva_loja_reporta/providers/home_provider.dart';
import 'package:eva_loja_reporta/repositories/incident_repository.dart';

void main() {
  testWidgets('App shows LojaReport title', (WidgetTester tester) async {
    final repository = IncidentRepository(DioClient());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HomeProvider(repository),
        child: const MyApp(),
      ),
    );

    expect(find.text('LojaReport'), findsOneWidget);
  });
}
