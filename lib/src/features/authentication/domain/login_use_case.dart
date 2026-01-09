import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'auth_repository.dart';
import 'user.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, User>> call(String email, String password) {
    return _repository.login(email, password);
  }
}
