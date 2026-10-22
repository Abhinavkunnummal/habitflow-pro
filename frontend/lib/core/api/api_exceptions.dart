import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.code = 'UNKNOWN_ERROR',
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timed out. Please check your internet connection.',
          code: 'TIMEOUT',
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Unable to connect to the server. Please check the backend URL and network.',
          code: 'NETWORK_ERROR',
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null && response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final errorObj = data['error'];
          if (errorObj is Map<String, dynamic>) {
            final code = errorObj['code']?.toString() ?? 'API_ERROR';
            final rawMessage = errorObj['message']?.toString() ?? 'An error occurred';
            final details = errorObj['details'];

            return ApiException(
              message: _mapToUserFriendlyMessage(code, rawMessage),
              code: code,
              statusCode: response.statusCode,
              details: details,
            );
          }
        }

        final statusCode = response?.statusCode;
        if (statusCode == 401) {
          return const ApiException(
            message: 'Session expired or invalid. Please sign in again.',
            code: 'UNAUTHORIZED',
            statusCode: 401,
          );
        } else if (statusCode == 403) {
          return const ApiException(
            message: 'Access denied. You do not have permission to perform this action.',
            code: 'FORBIDDEN',
            statusCode: 403,
          );
        } else if (statusCode == 404) {
          return const ApiException(
            message: 'Requested resource was not found.',
            code: 'NOT_FOUND',
            statusCode: 404,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ApiException(
            message: 'Server error. Please try again shortly.',
            code: 'SERVER_ERROR',
            statusCode: statusCode,
          );
        }

        return ApiException(
          message: 'Request failed with status ${response?.statusCode}.',
          code: 'BAD_RESPONSE',
          statusCode: response?.statusCode,
        );

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          code: 'CANCELLED',
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Security certificate verification failed.',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? 'An unexpected network error occurred.',
          code: 'UNKNOWN',
        );
    }
  }

  static String _mapToUserFriendlyMessage(String code, String defaultMessage) {
    switch (code) {
      case 'INVALID_CREDENTIALS':
        return 'Incorrect email or password. Please try again.';
      case 'DUPLICATE_EMAIL':
        return 'An account with this email address already exists.';
      case 'TOKEN_EXPIRED':
        return 'Your session has expired. Please sign in again.';
      case 'USER_NOT_FOUND':
        return 'User account not found.';
      case 'NOT_FOUND':
        return 'The requested habit or goal was not found.';
      case 'VALIDATION_ERROR':
        return 'Please check your inputs and try again.';
      default:
        return defaultMessage;
    }
  }

  @override
  String toString() => 'ApiException(code: $code, message: $message, statusCode: $statusCode)';
}
