import 'package:flutter/material.dart';

import '../models/incident.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  final Incident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorEstado = incident.isResolved ? Colors.green : Colors.red;
    final statusIcon = incident.isResolved
        ? Icon(Icons.check_circle, color: colorEstado, size: 20)
        : Icon(Icons.circle, color: colorEstado, size: 16);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorEstado.withValues(alpha: 0.15),
          child: statusIcon,
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
        onTap: onTap,
      ),
    );
  }
}
