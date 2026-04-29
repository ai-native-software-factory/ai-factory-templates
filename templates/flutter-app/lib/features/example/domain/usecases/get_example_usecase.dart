import 'package:equatable/equatable.dart';

/// Use case for getting a single example by ID
class GetExampleUseCase {
  final Future<dynamic> Function(String id) _repository;

  GetExampleUseCase(this._repository);

  Future<dynamic> call(String id) async {
    return _repository(id);
  }
}
