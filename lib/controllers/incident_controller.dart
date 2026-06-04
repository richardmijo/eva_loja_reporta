import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';

class IncidentController extends ChangeNotifier {
  // Singleton pattern
  static final IncidentController _instance = IncidentController._internal();
  factory IncidentController() => _instance;
  IncidentController._internal();

  final IncidentRepository _repository = IncidentRepository();

  List<Incident> _incidents = [];
  bool _isLoading = false;
  String _error = '';
  String _activeFilter = 'todos';

  List<Incident> get incidents => _incidents;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get activeFilter => _activeFilter;

  List<Incident> get filteredIncidents {
    if (_activeFilter == 'todos') return _incidents;
    return _incidents.where((i) => i.type == _activeFilter).toList();
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<void> loadIncidents() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final list = await _repository.fetchIncidents();
      // Preserve local favorite status when reloading data from the server
      _incidents = list.map((newIncident) {
        final existingIndex = _incidents.indexWhere((element) => element.id == newIncident.id);
        if (existingIndex != -1) {
          return newIncident.copyWith(isFavorite: _incidents[existingIndex].isFavorite);
        }
        return newIncident;
      }).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Incident? findById(String id) {
    try {
      return _incidents.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  void toggleFavorite(String id) {
    final index = _incidents.indexWhere((element) => element.id == id);
    if (index != -1) {
      final incident = _incidents[index];
      _incidents[index] = incident.copyWith(isFavorite: !incident.isFavorite);
      notifyListeners();
    }
  }
}
