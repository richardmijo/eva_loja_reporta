import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';
import 'package:dio/dio.dart';

class IncidentController extends ChangeNotifier {
  static final IncidentController _instance = IncidentController._internal();
  factory IncidentController() => _instance;
  IncidentController._internal();

  IncidentRepository _repository = IncidentRepository();

  @visibleForTesting
  set repository(IncidentRepository repo) {
    _repository = repo;
  }

  List<Incident> _incidentes = [];
  bool _cargando = false;
  String _error = '';
  String _filtro = 'todos';
  final Set<String> _favoritos = {};

  List<Incident> get incidentes => _incidentes;
  bool get cargando => _cargando;
  String get error => _error;
  String get filtro => _filtro;

  List<Incident> get incidentesFiltrados {
    if (_filtro == 'todos') return _incidentes;
    return _incidentes.where((i) => i.type == _filtro).toList();
  }

  void setFiltro(String nuevoFiltro) {
    if (_filtro != nuevoFiltro) {
      _filtro = nuevoFiltro;
      notifyListeners();
    }
  }

  bool esFavorito(String id) {
    return _favoritos.contains(id);
  }

  void toggleFavorito(String id) {
    if (_favoritos.contains(id)) {
      _favoritos.remove(id);
    } else {
      _favoritos.add(id);
    }
    notifyListeners();
  }

  Future<void> cargarIncidentes() async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      _incidentes = await _repository.fetchIncidents();
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _incidentes = [];
      _cargando = false;
      if (e is DioException) {
        _error = 'Error al cargar los incidentes: ${e.message}';
      } else {
        _error = 'Error al cargar los incidentes: $e';
      }
      notifyListeners();
    }
  }
}
