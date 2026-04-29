import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_client.dart';
import '../../data/datasources/example_remote_datasource.dart';
import '../../data/repositories/example_repository_impl.dart';
import '../../domain/entities/example_entity.dart';
import '../../domain/repositories/example_repository.dart';

// Data source provider
final exampleRemoteDataSourceProvider = Provider<ExampleRemoteDataSource>((ref) {
  return ExampleRemoteDataSource(NetworkClient.instance.dio);
});

// Repository provider
final exampleRepositoryProvider = Provider<ExampleRepository>((ref) {
  final dataSource = ref.watch(exampleRemoteDataSourceProvider);
  return ExampleRepositoryImpl(dataSource);
});

// Examples list provider
final examplesProvider = FutureProvider<List<ExampleEntity>>((ref) async {
  final repository = ref.watch(exampleRepositoryProvider);
  return repository.getExamples();
});

// Single example provider
final exampleByIdProvider = FutureProvider.family<ExampleEntity, String>((ref, id) async {
  final repository = ref.watch(exampleRepositoryProvider);
  return repository.getExampleById(id);
});

// Example notifier for state management
class ExampleNotifier extends AsyncNotifier<List<ExampleEntity>> {
  @override
  Future<List<ExampleEntity>> build() async {
    final repository = ref.watch(exampleRepositoryProvider);
    return repository.getExamples();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(exampleRepositoryProvider);
      return repository.getExamples();
    });
  }

  Future<void> createExample({
    required String title,
    required String description,
  }) async {
    final repository = ref.read(exampleRepositoryProvider);
    await repository.createExample(title: title, description: description);
    await refresh();
  }

  Future<void> deleteExample(String id) async {
    final repository = ref.read(exampleRepositoryProvider);
    await repository.deleteExample(id);
    await refresh();
  }
}

final exampleNotifierProvider =
    AsyncNotifierProvider<ExampleNotifier, List<ExampleEntity>>(() => ExampleNotifier());
