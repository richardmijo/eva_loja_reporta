import 'package:dio/dio.dart';

import '../core/config/api_config.dart';
import '../core/network/dio_client.dart';
import '../models/incident.dart';

class IncidentRepository {
  IncidentRepository(this._client);

  final DioClient _client;

  Future<List<Incident>> fetchIncidents() async {
    try {
      final response = await _client.dio.get(ApiConfig.incidentsPath);

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data
            .map((item) => Incident.fromJson(item as Map<String, dynamic>))
            .where((incident) =>
                incident.type == 'pothole' ||
                incident.type == 'lighting' ||
                incident.type == 'flooding')
            .toList();
      }

      throw Exception('Server returned status ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Could not load incidents: ${e.message}');
    }
  }
}
