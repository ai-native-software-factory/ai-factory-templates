import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor for logging network requests and responses
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 120,
      colors: true,
      printEmojis: false,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '┌──────────────────────────────────────────────────────────────┐\n'
      '│ REQUEST: ${options.method} ${options.uri}\n'
      '├──────────────────────────────────────────────────────────────┤\n'
      '│ Headers: ${options.headers}\n'
      '├──────────────────────────────────────────────────────────────┤\n'
      '│ Data: ${options.data ?? 'No body'}\n'
      '└──────────────────────────────────────────────────────────────┘',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '┌──────────────────────────────────────────────────────────────┐\n'
      '│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}\n'
      '├──────────────────────────────────────────────────────────────┤\n'
      '│ Data: ${_truncateData(response.data)}\n'
      '└──────────────────────────────────────────────────────────────┘',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '┌──────────────────────────────────────────────────────────────┐\n'
      '│ ERROR: ${err.type}\n'
      '│ URL: ${err.requestOptions.uri}\n'
      '├──────────────────────────────────────────────────────────────┤\n'
      '│ Message: ${err.message}\n'
      '│ Response: ${err.response?.data ?? 'No response'}\n'
      '└──────────────────────────────────────────────────────────────┘',
    );
    handler.next(err);
  }

  String _truncateData(dynamic data, {int maxLength = 500}) {
    final str = data?.toString() ?? 'No data';
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}... [truncated]';
  }
}
