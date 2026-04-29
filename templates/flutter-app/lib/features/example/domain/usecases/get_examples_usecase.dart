import 'package:equatable/equatable.dart';

/// Use case for getting all examples
class GetExamplesUseCase {
  final Future<List<dynamic>> Function() _repository;

  GetExamplesUseCase(this._repository);

  Future<List<dynamic>> call() async {
    return _repository();
  }
}
