import 'package:flutter/material.dart';
import '../models/incident.dart';

class IncidentController extends ChangeNotifier {
  // Singleton pattern
  static final IncidentController _instance = IncidentController._internal();
  factory IncidentController() => _instance;
  IncidentController._internal();

  List<Incident> _incidents = [];
  List<Incident> get incidents => _incidents;

  void setIncidents(List<Incident> list) {
    // Preserve local favorite status when reloading data from the server
    _incidents = list.map((newIncident) {
      final existingIndex = _incidents.indexWhere((element) => element.id == newIncident.id);
      if (existingIndex != -1) {
        return newIncident.copyWith(isFavorite: _incidents[existingIndex].isFavorite);
      }
      return newIncident;
    }).toList();
    notifyListeners();
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
