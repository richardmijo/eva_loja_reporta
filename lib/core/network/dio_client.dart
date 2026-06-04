import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(responseBody: true));
    }
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
