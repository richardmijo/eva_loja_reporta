import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/incident.dart';
import '../controllers/incident_controller.dart';

class DetailScreen extends StatelessWidget {
  final Incident incidentArg;

  const DetailScreen({super.key, required this.incidentArg});

  @override
  Widget build(BuildContext context) {
    final controller = IncidentController();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final incident = controller.findById(incidentArg.id) ?? incidentArg;
        final isFavorite = incident.isFavorite;

        final esResuelto = incident.status == 'resolved';
        final colorEstado = esResuelto ? Colors.green : Colors.orange;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Detalles del Incidente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Share',
                onPressed: () async {
                  final emoji = incident.status == 'resolved' ? '✅' : '🔴';
                  final textToCopy =
                      '$emoji Incident in ${incident.zone}: ${incident.title} '
                      'Status: ${incident.status} Reported on LojaReport · Loja, Ecuador';
                  await Clipboard.setData(ClipboardData(text: textToCopy));
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
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: isFavorite ? Colors.amber : Colors.white,
                ),
                onPressed: () {
                  controller.toggleFavorite(incident.id);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header details card
                Container(
                  width: double.infinity,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildEtiquetaTipo(incident.type, colorEstado),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorEstado.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              incident.status.toUpperCase(),
                              style: TextStyle(
                                color: colorEstado,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        incident.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A), // Slate 900
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      _buildFila(Icons.location_on_outlined, 'Zona/Sector', incident.zone),
                      const SizedBox(height: 12),
                      _buildFila(
                        esResuelto ? Icons.check_circle_outline : Icons.pending_actions_outlined,
                        'Estado actual',
                        esResuelto ? 'Resuelto' : 'Pendiente de atención',
                        colorValor: colorEstado,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Description card
                Container(
                  width: double.infinity,
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
                        'Descripción del Reporte',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B), // Slate 800
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        incident.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Back button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text(
                      'Volver a la lista',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEtiquetaTipo(String tipo, Color color) {
    final etiqueta = tipo == 'pothole'
        ? 'Bache / Calzada'
        : tipo == 'lighting'
        ? 'Alumbrado Público'
        : 'Inundación';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        etiqueta.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
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
        Icon(icono, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Text(
          '$etiqueta: ',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        Expanded(
          child: Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: colorValor ?? const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
