import 'package:flutter/material.dart';
import 'models/incident.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/about_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LojaReport',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/about': (context) => AboutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final incident = settings.arguments as Incident;
          return MaterialPageRoute(
            builder: (context) => DetailScreen(incident: incident),
          );
        }
        return null;
      },
    );
  }
}
