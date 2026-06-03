import 'package:dio/dio.dart';
import '../models/incident.dart';
import '../data/dio_client.dart';

class IncidentRepository {
  final Dio _dio = DioClient().dio;

  Future<List<Incident>> fetchIncidents() async {
    final response = await _dio.get('incidents');
    if (response.data is List) {
      final List<dynamic> dataList = response.data;
      return dataList.map((json) => Incident.fromJson(json)).toList();
    } else {
      throw Exception('Unexpected API response format');
    }
  }
}
