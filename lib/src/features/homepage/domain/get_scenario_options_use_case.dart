import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'home_repository.dart';
import 'scenario_option.dart';

class GetScenarioOptionsUseCase {
  final HomeRepository _repository;

  GetScenarioOptionsUseCase(this._repository);

  Future<Either<Failure, List<ScenarioOption>>> call() {
    return _repository.getScenarioOptions();
  }
}
