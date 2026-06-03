import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:eva_loja_reporta/main.dart';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..connectionTimeout = const Duration(milliseconds: 1);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('App basic smoke test', (WidgetTester tester) async {
    // Build our app and run async code to let HTTP call fail gracefully in test
    await tester.runAsync(() async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();
    });
  });
}
