import 'package:flutter/material.dart';
import '../models/incidente.dart';
import '../services/incidente_service.dart';

class HomeProvider extends ChangeNotifier {
  final IncidenteService _service = IncidenteService();

  List<Incidente> _incidentes = [];
  bool cargando = false;
  String error = '';
  String filtro = 'todos';

  List<Incidente> get incidentesFiltrados {
    if (filtro == 'todos') return _incidentes;
    return _incidentes.where((i) => i.type == filtro).toList();
  }

  Future<void> cargarIncidentes() async {
    cargando = true;
    error = '';
    notifyListeners();

    try {
      _incidentes = await _service.obtenerIncidentes();
    } catch (e) {
      error = 'Error al cargar los incidentes. Intenta de nuevo.';
    }

    cargando = false;
    notifyListeners();
  }

  void cambiarFiltro(String nuevoFiltro) {
    filtro = nuevoFiltro;
    notifyListeners();
  }
}
