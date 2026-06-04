import '../data/network/dio_client.dart';
import '../models/incident.dart';

class IncidentRepository {
  final DioClient _dioClient = DioClient();

  Future<List<Incident>> fetchIncidents() async {
    final response = await _dioClient.dio.get('incidents');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Incident.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load incidents: ${response.statusMessage}');
    }
  }
}
