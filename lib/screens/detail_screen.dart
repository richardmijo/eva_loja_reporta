import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/incident.dart';

class DetailScreen extends StatelessWidget {
  final Incident incident;

  const DetailScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final statusColor = incident.isPending ? Colors.orange : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Detail'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: incident.isPending ? Colors.red : Colors.green,
            ),
            onPressed: () => _shareIncident(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeLabel(incident.type, statusColor),
            const SizedBox(height: 16),
            Text(
              incident.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.location_on, 'Zone', incident.zone),
            const SizedBox(height: 12),
            _buildInfoRow(
              incident.isPending ? Icons.pending : Icons.check_circle,
              'Status',
              incident.status.toUpperCase(),
              valueColor: statusColor,
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
          ],
        ),
      ),
    );
  }

  // ── Share ────────────────────────────────────────────────────────────

  void _shareIncident(BuildContext context) {
    Clipboard.setData(ClipboardData(text: incident.shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────────

  Widget _buildTypeLabel(String type, Color color) {
    final label = type == 'pothole'
        ? 'Pothole'
        : type == 'lighting'
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
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
