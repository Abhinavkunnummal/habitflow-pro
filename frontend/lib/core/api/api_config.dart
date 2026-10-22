class ApiConfig {
  static const String defaultLocalUrl = 'http://10.0.2.2:5000/api/v1';
  static const String defaultLanUrl = 'http://192.168.1.100:5000/api/v1';
  static const String defaultProductionUrl = 'https://habitflow-backend.onrender.com/api/v1';

  // Can be configured via --dart-define=API_BASE_URL=https://...
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String getInitialBaseUrl() {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    return defaultProductionUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
