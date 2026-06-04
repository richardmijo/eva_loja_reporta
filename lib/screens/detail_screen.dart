import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/incident.dart';
import '../controllers/incident_controller.dart';

class DetailScreen extends StatelessWidget {
  final Incident incident;

  const DetailScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final esResuelto = incident.status == 'resolved';
    final colorEstado = esResuelto ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              final emoji = esResuelto ? '✅' : '🔴';
              final shareText = '$emoji Incident in ${incident.zone}: ${incident.title} Status: ${incident.status} Reported on LojaReport · Loja, Ecuador';
              await Clipboard.setData(ClipboardData(text: shareText));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          ListenableBuilder(
            listenable: IncidentController(),
            builder: (context, child) {
              final favorito = IncidentController().esFavorito(incident.id);
              return IconButton(
                icon: Icon(
                  favorito ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () => IncidentController().toggleFavorito(incident.id),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEtiquetaTipo(incident.type, colorEstado),
            const SizedBox(height: 16),
            Text(
              incident.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFila(Icons.location_on, 'Zone', incident.zone),
            const SizedBox(height: 12),
            _buildFila(
              esResuelto ? Icons.check_circle : Icons.pending,
              'Status',
              incident.status.toUpperCase(),
              colorValor: colorEstado,
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              incident.description,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.pop(),
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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
