import 'package:dio/dio.dart';
import '../models/incidente.dart';
import 'dio_client.dart';

class IncidenteService {
  final Dio _dio = DioClient.instance;

  Future<List<Incidente>> obtenerIncidentes() async {
    final response = await _dio.get('/incidents');
    final List data = response.data as List;
    return data.map((json) => Incidente.fromJson(json)).toList();
  }
}
