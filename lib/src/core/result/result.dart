abstract class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  });
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    return success(data);
  }
}

class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppFailure error;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    return failure(error);
  }
}

class AppFailure {
  const AppFailure({required this.message, this.code});

  final String message;
  final String? code;
}
