import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/incident.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<List<Incident>> getIncidents() async {
    final response = await _dio.get('/incidents');
    final List<dynamic> data = response.data;
    return data.map((json) => Incident.fromJson(json)).toList();
  }
}
