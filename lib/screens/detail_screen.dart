import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool favorito = false;

  void _compartirIncidente(
    BuildContext context,
    Map<String, dynamic> incidente,
  ) {
    final zone = incidente['zone']?.toString() ?? '';
    final title = incidente['title']?.toString() ?? '';
    final status = incidente['status']?.toString().toUpperCase() ?? '';
    final esResuelto = incidente['status'] == 'resolved';

    final icono = esResuelto ? '✅' : '⏳';

    final texto =
        '$icono Incident in $zone: $title\nStatus: $status\nReported on LojaReport • Loja, Ecuador';

    Clipboard.setData(ClipboardData(text: texto)).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final incidente = GoRouterState.of(context).extra as Map<String, dynamic>?;

    if (incidente == null) {
      return const Scaffold(
        body: Center(child: Text('No incident data received')),
      );
    }

    final esResuelto = incidente['status'] == 'resolved';
    final colorEstado = esResuelto ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share incident',
            onPressed: () => _compartirIncidente(context, incidente),
          ),
          IconButton(
            icon: Icon(favorito ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              setState(() {
                favorito = !favorito;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEtiquetaTipo(incidente['type']?.toString() ?? '', esResuelto),
            const SizedBox(height: 16),

            Text(
              incidente['title']?.toString() ?? 'Sin título',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _buildFila(
              Icons.location_on,
              'Zone',
              incidente['zone']?.toString() ?? 'N/A',
            ),

            const SizedBox(height: 12),

            _buildFila(
              esResuelto ? Icons.check_circle : Icons.pending,
              'Status',
              (incidente['status'] ?? 'N/A').toString().toUpperCase(),
              colorValor: colorEstado,
            ),

            const SizedBox(height: 24),

            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text(
              incidente['description']?.toString().isNotEmpty == true
                  ? incidente['description'].toString()
                  : 'No description available.',
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtiquetaTipo(String tipo, bool esResuelto) {
    String etiqueta;
    Color color;

    if (tipo == 'pothole') {
      etiqueta = 'Pothole';
      color = esResuelto ? Colors.green : Colors.orange;
    } else if (tipo == 'lighting') {
      etiqueta = 'Lighting';
      color = esResuelto ? Colors.green : Colors.orange;
    } else {
      etiqueta = 'Flooding';
      color = esResuelto ? Colors.green : Colors.orange;
    }

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
