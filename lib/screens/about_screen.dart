import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acerca de LojaReport',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Elegant gradient icon card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_city_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'LojaReport',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Versión 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sobre el Proyecto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'LojaReport permite a los ciudadanos de Loja reportar y consultar incidentes urbanos en la ciudad (baches, fallas de iluminación y desbordamiento por lluvias), fomentando la colaboración activa con las entidades municipales.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(Icons.school_outlined, size: 20, color: Colors.grey),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Proyecto Académico Integrador',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      'Universidad Internacional del Ecuador\nCampus Loja',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
