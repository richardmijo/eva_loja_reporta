import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';

class HomeProvider extends ChangeNotifier {
  final IncidentRepository _repository = IncidentRepository();

  List<Incident> _incidents = [];
  bool _loading = false;
  String _error = '';
  String _filter = 'todos';

  List<Incident> get incidents => _incidents;
  bool get loading => _loading;
  String get error => _error;
  String get filter => _filter;

  List<Incident> get filteredIncidents {
    if (_filter == 'todos') return _incidents;
    return _incidents.where((i) => i.type == _filter).toList();
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  Future<void> loadIncidents() async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      _incidents = await _repository.getIncidents();
    } catch (e) {
      _error = 'Error al cargar los incidentes: $e';
    }

    _loading = false;
    notifyListeners();
  }
}
