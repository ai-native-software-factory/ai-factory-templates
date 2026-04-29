import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/example_model.dart';

/// Remote data source for example feature
class ExampleRemoteDataSource {
  final Dio _dio;

  ExampleRemoteDataSource(this._dio);

  /// Fetch all examples
  Future<List<ExampleModel>> getExamples() async {
    final response = await _dio.get(ApiEndpoints.examples);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ExampleModel.fromJson(json)).toList();
  }

  /// Fetch a single example by ID
  Future<ExampleModel> getExampleById(String id) async {
    final response = await _dio.get(ApiEndpoints.exampleById(id));
    final data = response.data['data'] ?? response.data;
    return ExampleModel.fromJson(data);
  }

  /// Create a new example
  Future<ExampleModel> createExample({
    required String title,
    required String description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.examples,
      data: {
        'title': title,
        'description': description,
      },
    );
    final data = response.data['data'] ?? response.data;
    return ExampleModel.fromJson(data);
  }

  /// Update an existing example
  Future<ExampleModel> updateExample({
    required String id,
    String? title,
    String? description,
    bool? isActive,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.exampleById(id),
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (isActive != null) 'is_active': isActive,
      },
    );
    final data = response.data['data'] ?? response.data;
    return ExampleModel.fromJson(data);
  }

  /// Delete an example
  Future<void> deleteExample(String id) async {
    await _dio.delete(ApiEndpoints.exampleById(id));
  }
}
