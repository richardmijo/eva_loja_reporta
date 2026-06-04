import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../controllers/incident_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IncidentController _controller = IncidentController();

  @override
  void initState() {
    super.initState();
    _controller.loadIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LojaReport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(children: [_buildBarraFiltros(), _buildContenido()]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.loadIncidents,
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBarraFiltros() {
    return Container(
      height: 50,
      color: Colors.blue.shade50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChipFiltro('todos', 'All'),
          _buildChipFiltro('pothole', 'Potholes'),
          _buildChipFiltro('lighting', 'Lighting'),
          _buildChipFiltro('flooding', 'Flooding'),
        ],
      ),
    );
  }

  Widget _buildChipFiltro(String valor, String etiqueta) {
    final seleccionado = _controller.activeFilter == valor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: GestureDetector(
        onTap: () => _controller.setFilter(valor),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: seleccionado ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            etiqueta,
            style: TextStyle(
              color: seleccionado ? Colors.white : Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (_controller.isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (_controller.error.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_controller.error, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _controller.loadIncidents,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_controller.filteredIncidents.isEmpty) {
      return const Expanded(
        child: Center(child: Text('No incidents found for this filter.')),
      );
    }

    return Expanded(
      child: ListView(
        children: _controller.filteredIncidents
            .map((incidente) => _buildTarjetaIncidente(incidente))
            .toList(),
      ),
    );
  }

  Widget _buildTarjetaIncidente(Incident incidente) {
    final esResuelto = incidente.status == 'resolved';
    final colorEstado = esResuelto ? Colors.green : Colors.orange;
    final icono = incidente.type == 'pothole'
        ? Icons.warning_amber_rounded
        : incidente.type == 'lighting'
        ? Icons.lightbulb_outline
        : Icons.water_damage_outlined;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorEstado.withOpacity(0.15),
          child: Icon(icono, color: colorEstado, size: 20),
        ),
        title: Text(
          incidente.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zone: ${incidente.zone}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              incidente.status.toUpperCase(),
              style: TextStyle(
                color: colorEstado,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (incidente.isFavorite)
              const Icon(Icons.bookmark, color: Colors.orange, size: 18),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: incidente);
        },
      ),
    );
  }
}
