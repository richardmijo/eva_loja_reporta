import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/incident.dart';
import 'api_client.dart';

/// High-level HTTP operations; maps JSON to models in one place.
class ApiService {
  ApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Incident>> fetchIncidents() async {
    final response = await _apiClient.dio.get(ApiConfig.incidentsPath);

    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected status: ${response.statusCode}',
      );
    }

    final data = response.data as List<dynamic>;
    return data
        .map((item) => Incident.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
