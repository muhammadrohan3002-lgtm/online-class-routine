import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your network connection and backend server.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String msg = 'An unexpected server error occurred ($status)';

        if (data is Map && data['error'] != null) {
          msg = data['error'].toString();
        } else if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        } else if (status == 401) {
          msg = 'Session expired or invalid credentials. Please log in again.';
        } else if (status == 403) {
          msg = 'You do not have permission to perform this action.';
        } else if (status == 404) {
          msg = 'The requested resource was not found.';
        } else if (status == 409) {
          msg = data is Map && data['error'] != null ? data['error'].toString() : 'Conflict detected with existing record.';
        } else if (status == 500) {
          msg = 'Internal server error. Please try again later.';
        }

        return ApiException(
          message: msg,
          statusCode: status,
          details: data,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to connect to server. Ensure your backend is running at the configured URL.',
          statusCode: 503,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
        );

      default:
        return ApiException(
          message: error.message ?? 'An unknown network error occurred.',
        );
    }
  }

  @override
  String toString() => message;
}
