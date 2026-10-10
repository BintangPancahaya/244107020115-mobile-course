sealed class Failure {
  const Failure(this.message);
  final String message;
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Aturan bisnis dilanggar (mis. judul kosong). Ditambahkan untuk use case AddNote.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
