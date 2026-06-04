import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/incident_provider.dart';
import '../router/app_router.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LojaReport')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(child: _buildContent(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<IncidentProvider>().refresh(),
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    return Container(
      height: 50,
      color: Colors.blue.shade50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(context, provider, 'todos', 'All'),
          _buildFilterChip(context, provider, 'pothole', 'Potholes'),
          _buildFilterChip(context, provider, 'lighting', 'Lighting'),
          _buildFilterChip(context, provider, 'flooding', 'Flooding'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    IncidentProvider provider,
    String value,
    String label,
  ) {
    final selected = provider.filter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: GestureDetector(
        onTap: () => provider.setFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final provider = context.watch<IncidentProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(provider.error, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (provider.filteredIncidents.isEmpty) {
      return const Center(
        child: Text('No incidents found for this filter.'),
      );
    }

    return ListView.builder(
      itemCount: provider.filteredIncidents.length,
      itemBuilder: (context, index) {
        return _buildIncidentCard(
          context,
          provider.filteredIncidents[index],
        );
      },
    );
  }

  Widget _buildIncidentCard(BuildContext context, Incident incident) {
    final isResolved = incident.isResolved;
    final statusColor = isResolved ? Colors.green : Colors.orange;
    final icon = incident.type == 'pothole'
        ? Icons.warning_amber_rounded
        : incident.type == 'lighting'
        ? Icons.lightbulb_outline
        : Icons.water_damage_outlined;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(icon, color: statusColor, size: 20),
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
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          context.push(AppRoutes.detail, extra: incident);
        },
      ),
    );
  }
}
