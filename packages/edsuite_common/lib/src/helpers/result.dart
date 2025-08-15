sealed class Result<T, E> {}

class Success<T, E> extends Result<T, E> {
  Success(this.value);

  final T value;
}

class Err<T, E> extends Result<T, E> {
  Err(this.value);

  final E value;
}

extension ResultExtension<T, E> on Result<T, E> {
  bool get isSuccess => this is Success<T, E>;
  bool get isError => this is Err<T, E>;

  T? get successValue =>
      (this is Success<T, E>) ? (this as Success<T, E>).value : null;
  E? get errorValue => (this is Err<T, E>) ? (this as Err<T, E>).value : null;
}
