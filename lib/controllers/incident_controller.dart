import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';

class IncidentController extends ChangeNotifier {
  final IncidentRepository _repository = IncidentRepository();

  List<Incident> _incidents = [];
  bool _isLoading = false;
  String _error = '';
  String _filter = 'todos';

  List<Incident> get incidents => _incidents;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get filter => _filter;

  List<Incident> get filteredIncidents {
    if (_filter == 'todos') {
      return _incidents;
    }
    return _incidents.where((incident) => incident.type == _filter).toList();
  }

  Future<void> fetchIncidents() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _incidents = await _repository.getIncidents();
      _isLoading = false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
    }
    notifyListeners();
  }

  void setFilter(String newFilter) {
    if (_filter != newFilter) {
      _filter = newFilter;
      notifyListeners();
    }
  }
}
