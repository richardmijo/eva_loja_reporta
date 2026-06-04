import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información'),
      ),
      drawer: const AppDrawer(currentLocation: '/about'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.location_city, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'LojaReport',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Versión 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Autor: Jhandry Jaramillo',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const Text(
              'LojaReport permite a los ciudadanos de Loja consultar los incidentes '
              'urbanos reportados en la ciudad, incluyendo baches, problemas de '
              'alumbrado público e inundaciones.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Proyecto Comunitario',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Universidad Internacional del Ecuador — Campus Loja',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
