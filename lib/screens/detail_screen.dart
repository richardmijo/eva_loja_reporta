import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final Dio _dio = Dio();

  bool favorito = false;

  @override
  Widget build(BuildContext context) {
    final incidente =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final esResuelto = incidente['status'] == 'resolved';
    final colorEstado = esResuelto ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Detail'),
        actions: [
          IconButton(
            icon: Icon(
              favorito ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: () => setState(() => favorito = !favorito),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEtiquetaTipo(incidente['type'] ?? '', colorEstado),
            const SizedBox(height: 16),
            Text(
              incidente['title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFila(Icons.location_on, 'Zone', incidente['zone'] ?? ''),
            const SizedBox(height: 12),
            _buildFila(
              esResuelto ? Icons.check_circle : Icons.pending,
              'Status',
              (incidente['status'] ?? '').toString().toUpperCase(),
              colorValor: colorEstado,
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              incidente['description'] ?? '',
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtiquetaTipo(String tipo, Color color) {
    final etiqueta = tipo == 'pothole'
        ? 'Pothole'
        : tipo == 'lighting'
        ? 'Lighting'
        : 'Flooding';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        etiqueta.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildFila(
    IconData icono,
    String etiqueta,
    String valor, {
    Color? colorValor,
  }) {
    return Row(
      children: [
        Icon(icono, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$etiqueta: ',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Expanded(
          child: Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: colorValor,
            ),
          ),
        ),
      ],
    );
  }
}
