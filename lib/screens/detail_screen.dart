import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/incident.dart';
 
// StatelessWidget — this screen only reads data, it never mutates state.
// The old StatefulWidget + _DetailScreenState was unjustified (see ANALISIS.md §1).
class DetailScreen extends StatelessWidget {
  // Typed constructor — compiler error if caller forgets to pass an Incident.
  // Replaces the unsafe: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>
  final Incident incident;
 
  const DetailScreen({super.key, required this.incident});
 
  @override
  Widget build(BuildContext context) {
    final color = incident.isResolved ? Colors.green : Colors.orange;
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Detail'),
        // GoRouter handles the back button automatically — no manual button needed.
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share incident',
            onPressed: () => _shareIncident(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeBadge(incident.type, color),
            const SizedBox(height: 16),
            Text(
              incident.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildRow(Icons.location_on, 'Zone', incident.zone),
            const SizedBox(height: 12),
            _buildRow(
              incident.isResolved ? Icons.check_circle : Icons.pending,
              'Status',
              incident.status.toUpperCase(),
              valueColor: color,
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
          ],
        ),
      ),
    );
  }
 
  // Share: copies formatted text to clipboard and shows SnackBar confirmation.
  // Format: "[LojaReport] <title> — Zone: <zone> | Status: <status>"
  void _shareIncident(BuildContext context) {
    final text =
        '[LojaReport] ${incident.title} — Zone: ${incident.zone} | Status: ${incident.status.toUpperCase()}';
 
    Clipboard.setData(ClipboardData(text: text));
 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Incident copied to clipboard'),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
 
  Widget _buildTypeBadge(String type, Color color) {
    final label = type == 'pothole'
        ? 'Pothole'
        : type == 'lighting'
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
 
  Widget _buildRow(
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
 