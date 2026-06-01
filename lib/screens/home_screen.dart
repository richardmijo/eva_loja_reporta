import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// DECISIÓN 1: Dio se instancia directamente dentro del widget
// en lugar de inyectarlo o tenerlo en una capa de servicio separada.
// Cada vez que el widget se recrea, se crea una nueva instancia de Dio.

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // DECISIÓN 2: Dio instanciado como variable de instancia del State,
  // sin configuración base (baseUrl, timeouts, interceptors)
  final Dio _dio = Dio();

  List<dynamic> incidentes = [];
  bool cargando = false;
  String error = '';
  String filtro = 'todos';

  // DECISIÓN 3: contador que se incrementa dentro del build()
  int contadorRebuild = 0;

  @override
  void initState() {
    super.initState();
    cargarIncidentes();
  }

  // DECISIÓN 4: lógica de red, transformación de datos y manejo de estado
  // todo mezclado en un solo método dentro del widget
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
        final List<dynamic> datos = response.data;
        setState(() {
          incidentes = datos.take(20).map((item) {
            return {
              'id': item['id'],
              'titulo': item['title'],
              'descripcion': item['body'],
              'tipo': item['id'] % 3 == 0
                  ? 'bache'
                  : item['id'] % 3 == 1
                  ? 'alumbrado'
                  : 'inundacion',
              'estado': item['id'] % 2 == 0 ? 'resuelto' : 'pendiente',
              'zona': item['id'] % 4 == 0
                  ? 'Centro'
                  : item['id'] % 4 == 1
                  ? 'El Valle'
                  : item['id'] % 4 == 2
                  ? 'Carigán'
                  : 'Motupe',
            };
          }).toList();
          cargando = false;
        });
      }
    } on DioException catch (e) {
      // DECISIÓN 5: manejo de errores genérico que no distingue
      // entre error de red, timeout o error del servidor
      setState(() {
        error = 'Error al cargar los incidentes: ${e.message}';
        cargando = false;
      });
    }
  }

  List<dynamic> get incidentesFiltrados {
    if (filtro == 'todos') return incidentes;
    return incidentes.where((i) => i['tipo'] == filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    // DECISIÓN 6: lógica ejecutándose dentro del build()
    // esto corre cada vez que el widget se reconstruye
    contadorRebuild++;

    return Scaffold(
      appBar: AppBar(
        title: Text('LojaReport'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
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
          _buildChipFiltro('todos', 'Todos'),
          _buildChipFiltro('bache', 'Baches'),
          _buildChipFiltro('alumbrado', 'Alumbrado'),
          _buildChipFiltro('inundacion', 'Inundaciones'),
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
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (incidentesFiltrados.isEmpty) {
      return const Expanded(
        child: Center(child: Text('No hay incidentes para este filtro.')),
      );
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

  Widget _buildTarjetaIncidente(Map<String, dynamic> incidente) {
    final esResuelto = incidente['estado'] == 'resuelto';
    final colorEstado = esResuelto ? Colors.green : Colors.orange;
    final icono = incidente['tipo'] == 'bache'
        ? Icons.warning_amber_rounded
        : incidente['tipo'] == 'alumbrado'
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
          incidente['titulo'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zona: ${incidente['zona']}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              incidente['estado'].toString().toUpperCase(),
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
          Navigator.pushNamed(context, '/detail', arguments: incidente);
        },
      ),
    );
  }
}
