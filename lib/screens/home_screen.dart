import 'package:flutter/material.dart';
import '../controllers/incident_controller.dart';
import '../widgets/filter_bar.dart';
import '../widgets/incident_card.dart';

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
    _controller.cargarIncidentes();
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
      body: Column(
        children: [
          FilterBar(),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                if (_controller.cargando) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_controller.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            _controller.error,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _controller.cargarIncidentes,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                final incidentes = _controller.incidentesFiltrados;
                if (incidentes.isEmpty) {
                  return const Center(
                    child: Text('No incidents found for this filter.'),
                  );
                }
                return ListView.builder(
                  itemCount: incidentes.length,
                  itemBuilder: (context, index) {
                    return IncidentCard(incident: incidentes[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.cargarIncidentes,
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
