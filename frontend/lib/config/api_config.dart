class ApiConfig {
  // For Android emulator → use 10.0.2.2 to reach host machine's localhost
  // For physical device → use your machine's IP address
  // For web/desktop → use localhost
  static const String baseUrl = 'http://10.219.186.110:8000/api/v1';
  static const String healthCheckUrl = 'http://10.219.186.110:8000/health';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
