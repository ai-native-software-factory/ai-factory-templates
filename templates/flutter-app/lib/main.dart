import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/network_client.dart';
import 'core/storage/storage_service.dart';

/// Global error handler for uncaught exceptions
Future<void> _handleUncaughtException(
  Object error,
  StackTrace stackTrace,
  Logger logger,
) async {
  logger.e('Uncaught exception: $error', error: error, stackTrace: stackTrace);

  // Attempt to send error to crash reporting service
  // await CrashReportingService.report(error, stackTrace);

  // Exit application in release mode
  if (AppConfig.isRelease) {
    // ignore: avoid_print
    print('Application will exit due to uncaught exception in release mode');
    // Flush logs before exit
    logger.flush();
    exit(1);
  }
}

/// Global handler for unhandled promise rejections
Future<void> _handleUnhandledRejection(
  Object error,
  StackTrace stackTrace,
  Logger logger,
) async {
  logger.e('Unhandled rejection: $error',
      error: error, stackTrace: stackTrace);
}

/// Initialize services before runApp
Future<void> _initializeServices(Logger logger) async {
  logger.d('Initializing services...');

  // Set preferred orientations
  await _initializeOrientation();

  // Initialize local storage
  await StorageService.instance.initialize();
  logger.d('Storage initialized');

  // Initialize network client
  NetworkClient.instance.initialize();
  logger.d('Network client initialized');
}

/// Set preferred orientations based on platform
Future<void> _initializeOrientation() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    if (AppConfig.isTablet) ...[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
  ]);
}

/// Configure system UI overlay style
void _configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: !AppConfig.isRelease,
      printEmojis: !AppConfig.isRelease,
      printTime: AppConfig.isDebug,
    ),
  );

  // Configure logger level based on environment
  Logger.level = AppConfig.isDebug ? Level.debug : Level.warning;

  logger.d('Starting application...');
  logger.d('Environment: ${AppConfig.env}');
  logger.d('Is Release: ${AppConfig.isRelease}');
  logger.d('Is Debug: ${AppConfig.isDebug}');

  // Set system UI
  _configureSystemUI();

  // Set uncaught exception handler
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    logger.e('FlutterError: ${details.exceptionAsString()}',
        error: details.exception, stackTrace: details.stack);
    originalOnError?.call(details);
  };

  // Handle uncaught exceptions
  await runZonedGuarded(
    () async {
      // Initialize services
      await _initializeServices(logger);

      // Run the app with Riverpod
      runApp(
        const ProviderScope(
          child: App(),
        ),
      );
    },
    (error, stackTrace) => _handleUncaughtException(error, stackTrace, logger),
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, message) {
        // Route print statements through logger in release
        if (AppConfig.isRelease) {
          logger.d(message.toString());
        } else {
          parent.print(zone, message);
        }
      },
    ),
  );

  // Handle unhandled promise rejections
  await runZonedGuarded(
    () async {},
    (error, stackTrace) =>
        _handleUnhandledRejection(error, stackTrace, logger),
  );
}
