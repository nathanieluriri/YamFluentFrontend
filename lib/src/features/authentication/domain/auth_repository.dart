import 'package:fpdart/fpdart.dart';
import '../../../core/utils/failure.dart';
import 'user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> signUp(String name, String email, String password);
  Future<Either<Failure, String>> requestPasswordReset(String email);
  Future<Either<Failure, String>> confirmPasswordReset(String resetToken, String password);
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> refresh(String accessToken, String refreshToken);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> deleteAccount();
}
