import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../providers/home_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LojaReport'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Osyual Macas'),
              accountEmail: Text('osyual.macas@uide.edu.ec'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('OM', style: TextStyle(fontSize: 24, color: Colors.blue)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Información'),
              onTap: () {
                Navigator.pop(context);
                context.push('/about');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(context, provider),
          _buildContent(context, provider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => provider.loadIncidents(),
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, HomeProvider provider) {
    return Container(
      height: 50,
      color: Colors.blue.shade50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('todos', 'All', provider),
          _buildFilterChip('pothole', 'Potholes', provider),
          _buildFilterChip('lighting', 'Lighting', provider),
          _buildFilterChip('flooding', 'Flooding', provider),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, HomeProvider provider) {
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

  Widget _buildContent(BuildContext context, HomeProvider provider) {
    if (provider.loading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (provider.error.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(provider.error, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadIncidents(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (provider.filteredIncidents.isEmpty) {
      return const Expanded(
        child: Center(child: Text('No incidents found for this filter.')),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: provider.filteredIncidents.length,
        itemBuilder: (context, index) {
          final incident = provider.filteredIncidents[index];
          return _buildIncidentCard(context, incident);
        },
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, Incident incident) {
    final isResolved = incident.status == 'resolved';
    final statusColor = isResolved ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: Text(
          isResolved ? '✅' : '🔴',
          style: const TextStyle(fontSize: 24),
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
            Text('Zone: ${incident.zone}', style: const TextStyle(fontSize: 12)),
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
        onTap: () => context.push('/detail', extra: incident),
      ),
    );
  }
}
