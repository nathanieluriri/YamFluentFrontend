abstract class Failure {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(String message, {this.statusCode, StackTrace? stackTrace}) : super(message, stackTrace);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message, [super.stackTrace]);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.stackTrace]);
}
