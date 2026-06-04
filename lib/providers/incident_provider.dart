import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/incident.dart';
import '../repositories/incident_repository.dart';

class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._repository);

  final IncidentRepository _repository;

  List<Incident> _incidents = [];
  bool _loading = false;
  String _error = '';
  String _filter = 'todos';

  List<Incident> get incidents => List.unmodifiable(_incidents);
  bool get loading => _loading;
  String get error => _error;
  String get filter => _filter;

  List<Incident> get filteredIncidents {
    if (_filter == 'todos') return incidents;
    return incidents.where((i) => i.type == _filter).toList();
  }

  Future<void> load() async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      _incidents = await _repository.getIncidents();
    } on DioException catch (e) {
      _error = 'Error loading incidents: ${e.message}';
      _incidents = [];
    } catch (e) {
      _error = 'Error loading incidents: $e';
      _incidents = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  void setFilter(String value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }
}
