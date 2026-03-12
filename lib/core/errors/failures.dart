
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ApiFailure extends Failure {
  const ApiFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
