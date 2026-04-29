import '../../domain/entities/example_entity.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/example_remote_datasource.dart';

/// Implementation of ExampleRepository
class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleRemoteDataSource _remoteDataSource;

  ExampleRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ExampleEntity>> getExamples() async {
    final models = await _remoteDataSource.getExamples();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ExampleEntity> getExampleById(String id) async {
    final model = await _remoteDataSource.getExampleById(id);
    return model.toEntity();
  }

  @override
  Future<ExampleEntity> createExample({
    required String title,
    required String description,
  }) async {
    final model = await _remoteDataSource.createExample(
      title: title,
      description: description,
    );
    return model.toEntity();
  }

  @override
  Future<ExampleEntity> updateExample({
    required String id,
    String? title,
    String? description,
    bool? isActive,
  }) async {
    final model = await _remoteDataSource.updateExample(
      id: id,
      title: title,
      description: description,
      isActive: isActive,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteExample(String id) async {
    await _remoteDataSource.deleteExample(id);
  }
}
