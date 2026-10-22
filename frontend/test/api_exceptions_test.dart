import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow_pro/core/api/api_exceptions.dart';

void main() {
  group('ApiException Tests', () {
    test('should map timeout DioException correctly', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/habits'),
        type: DioExceptionType.connectionTimeout,
      );

      final apiError = ApiException.fromDioException(dioError);
      expect(apiError.code, 'TIMEOUT');
      expect(apiError.statusCode, 408);
      expect(apiError.message, contains('Connection timed out'));
    });

    test('should map connection error DioException correctly', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.connectionError,
      );

      final apiError = ApiException.fromDioException(dioError);
      expect(apiError.code, 'NETWORK_ERROR');
      expect(apiError.message, contains('Unable to connect to the server'));
    });

    test('should map backend JSON error with code and user-friendly message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {
            'success': false,
            'error': {
              'code': 'INVALID_CREDENTIALS',
              'message': 'Invalid email or password',
            },
          },
        ),
      );

      final apiError = ApiException.fromDioException(dioError);
      expect(apiError.code, 'INVALID_CREDENTIALS');
      expect(apiError.statusCode, 401);
      expect(apiError.message, 'Incorrect email or password. Please try again.');
    });

    test('should map DUPLICATE_EMAIL code to friendly explanation', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: 409,
          data: {
            'success': false,
            'error': {
              'code': 'DUPLICATE_EMAIL',
              'message': 'An account with this email address already exists',
            },
          },
        ),
      );

      final apiError = ApiException.fromDioException(dioError);
      expect(apiError.code, 'DUPLICATE_EMAIL');
      expect(apiError.statusCode, 409);
      expect(apiError.message, 'An account with this email address already exists.');
    });

    test('should map 500 internal server error', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/habits'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/habits'),
          statusCode: 500,
          data: 'Internal Server Error',
        ),
      );

      final apiError = ApiException.fromDioException(dioError);
      expect(apiError.code, 'SERVER_ERROR');
      expect(apiError.statusCode, 500);
      expect(apiError.message, contains('Server error'));
    });
  });
}
