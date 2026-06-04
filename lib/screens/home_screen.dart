import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        title: const Text(
          'LojaReport',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push('/about'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(
                'Fernando Castillo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: const Text('fecastilloar@uide.edu.ec'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.primary),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A), // Deep navy blue
                    Color(0xFF3B82F6), // Vibrant blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                context.pop();
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Información'),
              onTap: () {
                context.pop();
                context.push('/about');
              },
            ),
          ],
        ),
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
      height: 56,
      color: Colors.blue.shade50.withValues(alpha: 0.3),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: GestureDetector(
        onTap: () => _controller.setFilter(valor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: seleccionado
                ? LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: seleccionado ? null : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: seleccionado ? Colors.transparent : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: seleccionado
                ? [
                    BoxShadow(
                      color: secondaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Center(
            child: Text(
              etiqueta,
              style: TextStyle(
                color: seleccionado ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: colorEstado,
                width: 6,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: colorEstado.withValues(alpha: 0.1),
              child: Icon(icono, color: colorEstado, size: 22),
            ),
            title: Text(
              incidente.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        incidente.zone,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      incidente.status.toUpperCase(),
                      style: TextStyle(
                        color: colorEstado,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (incidente.isFavorite)
                  const Icon(Icons.bookmark, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
              ],
            ),
            onTap: () {
              context.push('/detail', extra: incidente);
            },
          ),
        ),
      ),
    );
  }
}
