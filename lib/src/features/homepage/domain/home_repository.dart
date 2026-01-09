import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'scenario_option.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, List<ScenarioOption>>> getScenarioOptions();
}
