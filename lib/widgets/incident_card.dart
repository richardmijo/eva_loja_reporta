import 'package:flutter/material.dart';
import '../models/incident.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;

  const IncidentCard({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final esResuelto = incident.status == 'resolved';
    final colorEstado = esResuelto ? Colors.green : Colors.orange;

    final icono = incident.type == 'pothole'
        ? Icons.warning_amber_rounded
        : incident.type == 'lighting'
            ? Icons.lightbulb_outline
            : Icons.water_damage_outlined;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorEstado.withValues(alpha: 0.15),
          child: Icon(icono, color: colorEstado, size: 20),
        ),
        title: Text(
          incident.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zone: ${incident.zone}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              incident.status.toUpperCase(),
              style: TextStyle(
                color: colorEstado,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: incident);
        },
      ),
    );
  }
}
