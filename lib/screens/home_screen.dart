import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/incident_service.dart';
import '../models/incident.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IncidentService _service = IncidentService();

  List<Incident> incidentes = [];
  bool cargando = false;
  String error = '';
  String filtro = 'todos';

  @override
  void initState() {
    super.initState();
    cargarIncidentes();
  }

  Future<void> cargarIncidentes() async {
    setState(() {
      cargando = true;
      error = '';
    });

    try {
      final data = await _service.getIncidents();
      setState(() {
        incidentes = data;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar incidentes';
        cargando = false;
      });
    }
  }

  List<Incident> get incidentesFiltrados {
    if (filtro == 'todos') return incidentes;
    return incidentes.where((i) => i.type == filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Malena Orbea'),
              accountEmail: Text('malena@uideloja.edu.ec'),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
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
              leading: const Icon(Icons.info),
              title: const Text('Información'),
              onTap: () {
                Navigator.pop(context);
                context.go('/about');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('LojaReport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              context.push('/about');
            },
          ),
        ],
      ),
      body: Column(children: [_buildBarraFiltros(), _buildContenido()]),
      floatingActionButton: FloatingActionButton(
        onPressed: cargarIncidentes,
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
    final seleccionado = filtro == valor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            filtro = valor;
          });
        },
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
    if (cargando) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (error.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(error),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: cargarIncidentes,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (incidentesFiltrados.isEmpty) {
      return const Expanded(child: Center(child: Text('No incidents found')));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: incidentesFiltrados.length,
        itemBuilder: (context, index) {
          return _buildTarjetaIncidente(incidentesFiltrados[index]);
        },
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorEstado.withOpacity(0.15),
          child: Icon(icono, color: colorEstado),
        ),
        title: Text(incidente.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zone: ${incidente.zone}'),
            Text(
              incidente.status.toUpperCase(),
              style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.push('/detail', extra: incidente.toMap());
        },
      ),
    );
  }
}
