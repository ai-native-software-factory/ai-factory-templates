import 'package:dio/dio.dart';

/// Custom exception types for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException(
          message: 'Connection timeout',
          statusCode: null,
        );
      case DioExceptionType.sendTimeout:
        return const ApiException(
          message: 'Send timeout',
          statusCode: null,
        );
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Receive timeout',
          statusCode: null,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Invalid SSL certificate',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request cancelled',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection',
          statusCode: null,
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? 'Unknown error occurred',
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    String message;
    switch (statusCode) {
      case 400:
        message = _extractErrorMessage(data) ?? 'Bad request';
        break;
      case 401:
        message = 'Unauthorized - Please login again';
        break;
      case 403:
        message = 'Forbidden - You don\'t have permission';
        break;
      case 404:
        message = 'Resource not found';
        break;
      case 409:
        message = 'Conflict - Resource already exists';
        break;
      case 422:
        message = 'Validation error';
        break;
      case 429:
        message = 'Too many requests - Please try again later';
        break;
      case 500:
        message = 'Internal server error';
        break;
      case 502:
        message = 'Bad gateway';
        break;
      case 503:
        message = 'Service unavailable';
        break;
      case 504:
        message = 'Gateway timeout';
        break;
      default:
        message = _extractErrorMessage(data) ?? 'Error occurred';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      return data['message'] ??
          data['error'] ??
          data['error_message'] ??
          data['detail'];
    }
    return null;
  }
}

/// Interceptor for handling API errors consistently
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = ApiException.fromDioException(err);

    // Log the error
    // LoggerService.instance.e('API Error: $apiException');

    // You can perform specific actions based on error type
    if (err.response?.statusCode == 401) {
      // Handle unauthorized - maybe refresh token or logout
      // _handleUnauthorized();
    }

    // Create a more descriptive error
    final customError = DioException(
      requestOptions: err.requestOptions,
      error: apiException.message,
      type: err.type,
      response: err.response,
      headers: err.headers,
      statusCode: err.statusCode,
    );

    handler.next(customError);
  }
}
