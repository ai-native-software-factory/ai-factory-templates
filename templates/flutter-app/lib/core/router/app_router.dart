import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/example/presentation/pages/example_page.dart';
import '../../features/example/presentation/pages/example_detail_page.dart';
import '../../shared/widgets/pages/splash_page.dart';
import '../../shared/widgets/pages/error_page.dart';
import 'route_names.dart';

/// Route paths
class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String example = '/example';
  static const String exampleDetail = '/example/:id';
  static const String error = '/error';
}

/// GoRouter configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: _routes,
    errorBuilder: (context, state) => ErrorPage(
      error: state.error,
    ),
    redirect: (context, state) {
      // Add global redirect logic here
      // e.g., check auth state and redirect to login
      return null;
    },
  );
});

/// Application routes
final _routes = <RouteBase>[
  // Splash
  GoRoute(
    path: RoutePaths.splash,
    name: RouteNames.splash,
    builder: (context, state) => const SplashPage(),
  ),

  // Example feature
  GoRoute(
    path: RoutePaths.example,
    name: RouteNames.example,
    builder: (context, state) => const ExamplePage(),
    routes: [
      GoRoute(
        path: ':id',
        name: RouteNames.exampleDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExampleDetailPage(id: id);
        },
      ),
    ],
  ),

  // Error page
  GoRoute(
    path: RoutePaths.error,
    name: RouteNames.error,
    builder: (context, state) => const ErrorPage(),
  ),
];

/// Navigation extension for GoRouter
extension GoRouterNavigation on BuildContext {
  void goToExample() => goNamed(RouteNames.example);

  void goToExampleDetail(String id) => goNamed(
        RouteNames.exampleDetail,
        pathParameters: {'id': id},
      );

  void goToError() => goNamed(RouteNames.error);

  Future<T?> pushToExample<T>() => pushNamed<T>(RouteNames.example);

  Future<T?> pushToExampleDetail<T>(String id) => pushNamed<T>(
        RouteNames.exampleDetail,
        pathParameters: {'id': id},
      );
}
