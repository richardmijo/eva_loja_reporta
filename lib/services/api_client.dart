import 'package:dio/dio.dart';

import '../config/api_config.dart';

/// Single configured Dio instance for the whole app.
class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? Dio(_baseOptions);

  final Dio _dio;

  static BaseOptions get _baseOptions => BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      );

  Dio get dio => _dio;
}
