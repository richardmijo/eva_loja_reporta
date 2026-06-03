import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/incident_controller.dart';
import '../models/incident.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IncidentController _controller = IncidentController();

  @override
  void initState() {
    super.initState();
    _controller.fetchIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LojaReport'),
      ),
      drawer: _buildDrawer(context),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            children: [
              _buildBarraFiltros(),
              _buildContenido(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.fetchIncidents,
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text(
              'Gabriel Sarango',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text('gabriel.sarango@uide.edu.ec'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue, size: 40),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cerrar Drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('Información'),
            onTap: () {
              Navigator.pop(context); // Cerrar Drawer
              context.push('/about');
            },
          ),
        ],
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
    final seleccionado = _controller.filter == valor;
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _controller.error,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _controller.fetchIncidents,
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
      child: ListView.builder(
        itemCount: _controller.filteredIncidents.length,
        itemBuilder: (context, index) {
          final incident = _controller.filteredIncidents[index];
          return _buildTarjetaIncidente(incident);
        },
      ),
    );
  }

  Widget _buildTarjetaIncidente(Incident incident) {
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
          backgroundColor: colorEstado.withOpacity(0.15),
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
          context.push('/detail', extra: incident);
        },
      ),
    );
  }
}
