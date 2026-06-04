import '../models/incident.dart';
import '../services/api_service.dart';

class IncidentRepository {
  IncidentRepository(this._apiService);

  final ApiService _apiService;

  Future<List<Incident>> getIncidents() => _apiService.fetchIncidents();
}
