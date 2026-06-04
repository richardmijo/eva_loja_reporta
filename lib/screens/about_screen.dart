import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.blue,
              child: Icon(Icons.location_city, color: Colors.white, size: 36),
            ),
            SizedBox(height: 20),
            Text(
              'LojaReport',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              'LojaReport allows citizens of Loja to consult urban incidents '
              'reported in the city, including potholes, lighting problems '
              'and flooding.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            SizedBox(height: 32),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Community project',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Universidad Internacional del Ecuador — Campus Loja',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
