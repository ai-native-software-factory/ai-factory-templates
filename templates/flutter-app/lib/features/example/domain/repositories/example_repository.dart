import '../entities/example_entity.dart';

/// Repository interface for example feature
/// Following clean architecture, this is in the domain layer
/// and defines the contract that the data layer must implement
abstract class ExampleRepository {
  /// Get all examples
  Future<List<ExampleEntity>> getExamples();

  /// Get a single example by ID
  Future<ExampleEntity> getExampleById(String id);

  /// Create a new example
  Future<ExampleEntity> createExample({
    required String title,
    required String description,
  });

  /// Update an existing example
  Future<ExampleEntity> updateExample({
    required String id,
    String? title,
    String? description,
    bool? isActive,
  });

  /// Delete an example by ID
  Future<void> deleteExample(String id);
}
