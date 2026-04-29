import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'api_endpoints.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Network client singleton using Dio
class NetworkClient {
  NetworkClient._();
  static final NetworkClient instance = NetworkClient._();

  late final Dio _dio;
  Dio get dio => _dio;

  bool _isInitialized = false;

  /// Initialize the network client
  void initialize() {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        sendTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Platform': 'mobile',
          'X-App-Version': '1.0.0',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      LoggingInterceptor(),
      ErrorInterceptor(),
      RetryInterceptor(dio: _dio),
    ]);

    // Set up logging in debug mode
    if (AppConfig.isDebug) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    _isInitialized = true;
  }

  /// Get authenticated Dio instance with auth token
  Dio get authenticatedDio {
    final authDio = Dio(_dio.options);
    // Add auth interceptor or token header here
    // authDio.interceptors.add(AuthInterceptor());
    return authDio;
  }

  /// Reset the client (for testing or re-initialization)
  void reset() {
    _dio.close();
    _isInitialized = false;
  }
}

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  return NetworkClient.instance.dio;
});

/// Provider for API endpoints
final apiEndpointsProvider = Provider<ApiEndpoints>((ref) {
  return ApiEndpoints(NetworkClient.instance.dio);
});
