import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// DECISIÓN 7: DetailScreen es StatefulWidget pero casi no tiene estado real.
// Además crea su propia instancia de Dio para una sola llamada puntual,
// completamente separada del Dio que usa HomeScreen.
class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final Dio _dio = Dio();
  bool favorito = false;
  Map<String, dynamic>? incidenteDetallado;
  bool cargandoDetalle = false;

  @override
  void initState() {
    super.initState();
    // DECISIÓN 8: se hace una segunda llamada a la API para obtener
    // el "detalle" del incidente, aunque HomeScreen ya tiene todos los datos.
    // Esto genera una petición de red innecesaria cada vez que se abre el detalle.
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    // Nota: los argumentos no están disponibles en initState,
    // así que este método no puede usar el id del incidente todavía.
    // El desarrollador lo dejó pendiente de resolver.
    setState(() => cargandoDetalle = false);
  }

  @override
  Widget build(BuildContext context) {
    // DECISIÓN 9: los argumentos se castean sin null-check.
    // Si alguien navega a /detail sin pasar argumentos, la app explota.
    final incidente =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final esResuelto = incidente['estado'] == 'resuelto';
    final colorEstado = esResuelto ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del incidente'),
        actions: [
          // DECISIÓN 10: el estado "favorito" se guarda localmente en el widget.
          // Cuando el usuario vuelve atrás y regresa, el favorito se pierde.
          // Además HomeScreen no sabe que este incidente fue marcado como favorito.
          IconButton(
            icon: Icon(
              favorito ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: () => setState(() => favorito = !favorito),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEtiquetaTipo(incidente['tipo'], colorEstado),
            const SizedBox(height: 16),
            Text(
              incidente['titulo'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildFila(Icons.location_on, 'Zona', incidente['zona']),
            const SizedBox(height: 12),
            _buildFila(
              esResuelto ? Icons.check_circle : Icons.pending,
              'Estado',
              incidente['estado'].toString().toUpperCase(),
              colorValor: colorEstado,
            ),
            const SizedBox(height: 24),
            const Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              incidente['descripcion'],
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            // DECISIÓN 11: usa pushNamed('/') en lugar de pop().
            // Esto agrega HomeScreen al stack en lugar de volver a la anterior.
            // Si el usuario presiona este botón varias veces, el stack
            // acumula instancias y el botón de atrás del sistema no funciona como espera.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtiquetaTipo(String tipo, Color color) {
    final etiqueta = tipo == 'bache'
        ? 'Bache'
        : tipo == 'alumbrado'
            ? 'Alumbrado'
            : 'Inundación';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        etiqueta.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildFila(IconData icono, String etiqueta, String valor,
      {Color? colorValor}) {
    return Row(
      children: [
        Icon(icono, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$etiqueta: ',
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colorValor,
          ),
        ),
      ],
    );
  }
}
