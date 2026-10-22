import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/session_storage.dart';
import 'api_config.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final SessionStorage _sessionStorage;
  final VoidCallback? onUnauthorized;

  ApiClient({
    required SessionStorage sessionStorage,
    this.onUnauthorized,
  }) : _sessionStorage = sessionStorage {
    final baseUrl = _sessionStorage.getCustomBaseUrl() ?? ApiConfig.getInitialBaseUrl();

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Inject JWT Bearer Token if available
          final token = _sessionStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
            if (sanitizedHeaders.containsKey('Authorization')) {
              sanitizedHeaders['Authorization'] = 'Bearer [REDACTED]';
            }
            debugPrint('[API REQUEST] ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('[API RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            debugPrint('[API ERROR] ${error.response?.statusCode} ${error.requestOptions.uri}');
          }

          // Handle 401 Unauthorized or Expired Token
          if (error.response?.statusCode == 401) {
            _sessionStorage.clearSession();
            onUnauthorized?.call();
          }

          return handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  String get currentBaseUrl => _dio.options.baseUrl;

  // --- Generic HTTP Request Wrappers with Normalized ApiException Handling ---

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _extractData(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  dynamic _extractData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }
}
