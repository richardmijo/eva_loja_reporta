import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/incident.dart';

class IncidentService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(seconds: ApiConfig.timeoutSeconds),
      receiveTimeout: Duration(seconds: ApiConfig.timeoutSeconds),
    ),
  );

  Future<List<Incident>> getIncidents() async {
    final response = await _dio.get('/incidents');
    final List<dynamic> data = response.data;
    return data.map((json) => Incident.fromJson(json)).toList();
  }
}
