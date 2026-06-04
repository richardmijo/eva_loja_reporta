import 'package:dio/dio.dart';

import '../models/incident.dart';
import '../network/api_client.dart';

class IncidentService {
  final Dio _dio;

  IncidentService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  /// Fetches all incidents from the API and returns them as typed objects.
  Future<List<Incident>> getIncidents() async {
    final response = await _dio.get('/incidents');
    final List<dynamic> data = response.data;
    return data.map((json) => Incident.fromJson(json)).toList();
  }
}
