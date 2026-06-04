/// Centralized API configuration. Change base URL here only.
class ApiConfig {
  static const String baseUrl =
      'https://6a1cf27ebcc4f20d5ca3b7bc.mockapi.io/api/v1';
  static const String incidentsPath = '/incidents';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
