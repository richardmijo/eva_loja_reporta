import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );

    // Ready for future interceptors (auth, logging, caching, etc.)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
      ),
    );
  }
}
