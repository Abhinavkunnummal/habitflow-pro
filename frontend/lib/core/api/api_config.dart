class ApiConfig {
  static const String defaultLocalUrl = 'http://10.0.2.2:5000/api/v1';
  static const String defaultLanUrl = 'http://192.168.1.2:5000/api/v1';
  static const String defaultProductionUrl = 'https://habitflow-pro-bz24.onrender.com/api/v1';

  // Can be configured via --dart-define=API_BASE_URL=https://...
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String getInitialBaseUrl() {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    // Default to Render Cloud for seamless physical device and multi-user testing
    return defaultProductionUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
}
