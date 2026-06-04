import 'package:flutter_test/flutter_test.dart';

import 'package:eva_loja_reporta/main.dart';

void main() {
  testWidgets('Smoke test - App renders LojaReport title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title 'LojaReport' is displayed.
    expect(find.text('LojaReport'), findsOneWidget);
  });
}
