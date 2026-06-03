import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../models/incident.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Dio _dio = Dio();

  List<dynamic> incidentes = [];
  bool cargando = false;
  String error = '';
  String filtro = 'todos';

  int contadorRebuild = 0;

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
      final response = await _dio.get(
        'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1/incidents',
      );

      if (response.statusCode == 200) {
        setState(() {
          incidentes = response.data;
          cargando = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        error = 'Error al cargar los incidentes: ${e.message}';
        cargando = false;
      });
    }
  }

  List<dynamic> get incidentesFiltrados {
    if (filtro == 'todos') return incidentes;
    return incidentes.where((i) => i['type'] == filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    contadorRebuild++;

    return Scaffold(
      appBar: AppBar(
        title: Text('LojaReport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push('/about'),
          ),
        ],
      ),
      body: Column(children: [_buildBarraFiltros(), _buildContenido()]),
      floatingActionButton: FloatingActionButton(
        onPressed: cargarIncidentes,
        tooltip: 'Actualizar',
        child: Icon(Icons.refresh),
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
        onTap: () => setState(() => filtro = valor),
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
              Text(error, style: const TextStyle(color: Colors.grey)),
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
      return const Expanded(
        child: Center(child: Text('No incidents found for this filter.')),
      );
    }

    return Expanded(
      child: ListView(
        children: incidentesFiltrados
            .map((incidente) => _buildTarjetaIncidente(incidente))
            .toList(),
      ),
    );
  }

  Widget _buildTarjetaIncidente(dynamic incidente) {
    final esResuelto = incidente['status'] == 'resolved';
    final colorEstado = esResuelto ? Colors.green : Colors.orange;
    final icono = incidente['type'] == 'pothole'
        ? Icons.warning_amber_rounded
        : incidente['type'] == 'lighting'
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
          incidente['title'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zone: ${incidente['zone'] ?? ''}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              (incidente['status'] ?? '').toString().toUpperCase(),
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
          final incidentObj = Incident.fromJson(incidente as Map<String, dynamic>);
          context.push('/detail', extra: incidentObj);
        },
      ),
    );
  }
}
