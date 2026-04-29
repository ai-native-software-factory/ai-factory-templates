import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../config/app_config.dart';

/// Interceptor that retries failed requests
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Logger _logger = Logger();

  RetryInterceptor({
    required this.dio,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on connection errors and timeouts
    final shouldRetry = _shouldRetry(err);

    if (!shouldRetry) {
      return handler.next(err);
    }

    // Get retry count from extra data or default to 0
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (retryCount >= AppConfig.maxRetries) {
      _logger.w('Max retries ($retryCount) reached for ${err.requestOptions.uri}');
      return handler.next(err);
    }

    _logger.d('Retrying request (attempt ${retryCount + 1}/${AppConfig.maxRetries}): '
        '${err.requestOptions.uri}');

    // Update retry count in extra data
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    // Exponential backoff delay
    final delay = Duration(milliseconds: (500 * (retryCount + 1)).toInt());
    await Future.delayed(delay);

    try {
      // Retry the request
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    // Retry on connection-related errors
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.type == DioExceptionType.badResponse &&
            err.response?.statusCode == 503);
  }
}
