import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/filter_bar.dart';
import '../widgets/incident_card.dart';

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
      context.read<HomeProvider>().loadIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('LojaReport')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          FilterBar(
            selected: provider.filtro,
            onSelected: provider.setFiltro,
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: provider.loadIncidents,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody(HomeProvider provider) {
    if (provider.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                provider.error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.loadIncidents,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final incidentes = provider.incidentesFiltrados;
    if (incidentes.isEmpty) {
      return const Center(
        child: Text('No incidents found for this filter.'),
      );
    }

    return ListView.builder(
      itemCount: incidentes.length,
      itemBuilder: (context, index) {
        final incident = incidentes[index];
        return IncidentCard(
          incident: incident,
          onTap: () => context.push('/detail', extra: incident),
        );
      },
    );
  }
}
