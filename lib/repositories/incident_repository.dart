import '../models/incident.dart';
import '../services/api_client.dart';

class IncidentRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<Incident>> getIncidents() async {
    final response = await _apiClient.dio.get('/incidents');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Incident.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load incidents (status code: ${response.statusCode})');
    }
  }
}
