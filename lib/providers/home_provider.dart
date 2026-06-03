import 'package:flutter/foundation.dart';

import '../models/incident.dart';
import '../repositories/incident_repository.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(this._repository);

  final IncidentRepository _repository;

  List<Incident> _incidentes = [];
  bool _cargando = false;
  String _error = '';
  String _filtro = 'todos';

  List<Incident> get incidentes => _incidentes;
  bool get cargando => _cargando;
  String get error => _error;
  String get filtro => _filtro;

  List<Incident> get incidentesFiltrados {
    if (_filtro == 'todos') return _incidentes;
    return _incidentes.where((i) => i.type == _filtro).toList();
  }

  Future<void> loadIncidents() async {
    _cargando = true;
    _error = '';
    notifyListeners();

    try {
      _incidentes = await _repository.fetchIncidents();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void setFiltro(String value) {
    _filtro = value;
    notifyListeners();
  }
}
