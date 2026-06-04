import '../models/incident.dart';
import '../services/api_client.dart';
 
class IncidentRepository {
  final _client = ApiClient();
 
  Future<List<Incident>> fetchIncidents() async {
    final response = await _client.dio.get('/incidents');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => Incident.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}