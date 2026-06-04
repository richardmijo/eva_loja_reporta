import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/incident.dart';

class IncidentRepository {
  final Dio _dio = DioClient().dio;

  Future<List<Incident>> getIncidents() async {
    final response = await _dio.get('/incidents');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      final validTypes = ['pothole', 'lighting', 'flooding'];
      return data
          .map((json) => Incident.fromJson(json))
          .where((i) => validTypes.contains(i.type))
          .toList();
    } else {
      throw Exception('Error al cargar incidentes: ${response.statusCode}');
    }
  }
}
