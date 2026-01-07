import 'dart:async';

import '../result_dart.dart';

/// `AsyncResultDart<S, E>` represents an asynchronous computation.
typedef AsyncResultDart<S extends Object, F extends Object>
    = Future<ResultDart<S, F>>;

/// `AsyncResultDart<S, E>` represents an asynchronous computation.
extension AsyncResultDartExtension<S extends Object, F extends Object> //
    on AsyncResultDart<S, F> {
  /// Returns a new `Result`, mapping any `Success` value
  /// using the given transformation and unwrapping the produced `Result`.
  AsyncResultDart<W, F> flatMap<W extends Object>(
    FutureOr<ResultDart<W, F>> Function(S success) fn,
  ) {
    return then((result) => result.match(fn, Err.new));
  }

  /// Returns a new `Result`, mapping any `Error` value
  /// using the given transformation and unwrapping the produced `Result`.
  AsyncResultDart<S, W> flatMapError<W extends Object>(
    FutureOr<ResultDart<S, W>> Function(F error) fn,
  ) {
    return then((result) => result.match(Ok.new, fn));
  }

  /// Returns a new `AsyncResultDart`, mapping any `Success` value
  /// using the given transformation.
  AsyncResultDart<W, F> map<W extends Object>(
    FutureOr<W> Function(S success) fn,
  ) {
    return then(
      (result) => result.map(fn).match(
        (success) async {
          return Ok(await success);
        },
        (failure) {
          return Err(failure);
        },
      ),
    );
  }

  /// Returns a new `Result`, mapping any `Error` value
  /// using the given transformation.
  AsyncResultDart<S, W> mapError<W extends Object>(
    FutureOr<W> Function(F error) fn,
  ) {
    return then(
      (result) => result.mapError(fn).match(
        (success) {
          return Ok(success);
        },
        (failure) async {
          return Err(await failure);
        },
      ),
    );
  }

  /// Change a [Success] value.
  AsyncResultDart<W, F> pure<W extends Object>(W success) {
    return then((result) => result.pure(success));
  }

  /// Change the [Failure] value.
  AsyncResultDart<S, W> pureError<W extends Object>(W error) {
    return mapError((_) => error);
  }

  /// Swap the values contained inside the [Success] and [Failure]
  /// of this [AsyncResultDart].
  AsyncResultDart<F, S> swap() {
    return then((result) => result.swap());
  }

  /// Returns the Future result of onSuccess for the encapsulated value
  /// if this instance represents `Success` or the result of onError function
  /// for the encapsulated value if it is `Error`.
  Future<W> match<W>(
    W Function(S success) onSuccess,
    W Function(F error) onError,
  ) {
    return then<W>((result) => result.match(onSuccess, onError));
  }

  /// Returns the future value of [S] if any.
  Future<S?> getOrNull() {
    return then((result) => result.getOrNull());
  }

  /// Returns the future value of [F] if any.
  Future<F?> exceptionOrNull() {
    return then((result) => result.exceptionOrNull());
  }

  /// Returns true if the current result is an [Failure].
  Future<bool> isErr() {
    return then((result) => result.isErr());
  }

  /// Returns true if the current result is a [Success].
  Future<bool> isOk() {
    return then((result) => result.isOk());
  }

  /// Returns the success value as a throwing expression.
  Future<S> getOrThrow() {
    return then((result) => result.getOrThrow());
  }

  /// Returns the encapsulated value if this instance represents `Success`
  /// or the result of `onFailure` function for
  /// the encapsulated a `Failure` value.
  Future<S> getOrElse(S Function(F) onFailure) {
    return then((result) => result.getOrElse(onFailure));
  }

  /// Returns the encapsulated value if this instance represents
  /// `Success` or the `defaultValue` if it is `Failure`.
  Future<S> getOrDefault(S defaultValue) {
    return then((result) => result.getOrDefault(defaultValue));
  }

  /// Returns the encapsulated `Result` of the given transform function
  /// applied to the encapsulated a `Failure` or the original
  /// encapsulated value if it is success.
  AsyncResultDart<S, R> recover<R extends Object>(
    FutureOr<ResultDart<S, R>> Function(F failure) onFailure,
  ) {
    return then((result) => result.match(Ok.new, onFailure));
  }

  /// Performs the given action on the encapsulated Throwable
  /// exception if this instance represents failure.
  /// Returns the original Result unchanged.
  AsyncResultDart<S, F> onErr(void Function(F failure) onFailure) {
    return then((result) => result.onErr(onFailure));
  }

  /// Performs the given action on the encapsulated value if this
  /// instance represents success. Returns the original Result unchanged.
  AsyncResultDart<S, F> onOk(void Function(S success) onSuccess) {
    return then((result) => result.onOk(onSuccess));
  }

  /// Returns the encapsulated value if this instance represents `Success`
  /// or the result of `onFailure` function for
  /// the encapsulated a `Failure` value.
  AsyncResultDart<G, W> pureFold<G extends Object, W extends Object>(
    G success,
    W failure,
  ) {
    return then((result) => result.pureFold(success, failure));
  }

  /// Returns the encapsulated value if this instance represents `Success`
  /// or the result of `onFailure` function for
  /// the encapsulated a `Failure` value.
  AsyncResultDart<G, W> mapFold<G extends Object, W extends Object>(
    G Function(S success) onSuccess,
    W Function(F error) onError,
  ) {
    return then((result) => result.mapFold(onSuccess, onError));
  }
}

/// Extension on `Future<S>` to convert it into an `AsyncResultDart<S, Exception>`.
///
/// This extension provides a method `toAsyncResult` that wraps the result of a
/// `Future` into a `Success` or `Failure` object. If the `Future` completes
/// successfully, the result is wrapped in a `Success`. If an exception occurs,
/// the exception is wrapped in a `Failure`.
///
/// Example usage:
/// ```dart
/// Future<int> future = Future.value(42);
/// AsyncResultDart<int, Exception> result = await future.toAsyncResult();
/// ```
extension FutureResultExtension<S extends Object> on Future<S> {
  AsyncResultDart<S, Exception> toAsyncResult() async {
    try {
      final value = await this;
      return Ok(value);
    } on Exception catch (e) {
      return Err(e);
    }
  }
}

/// Extension on `Future<void>` to convert it into an `AsyncResultDart<Unit, Exception>`.
///
/// This extension provides a method `toAsyncResult` that wraps the completion
/// of a `Future<void>` into a `Success` or `Failure` object. If the `Future`
/// completes successfully, a `Success` containing `unit` is returned. If an
/// exception occurs, the exception is wrapped in a `Failure`.
///
/// Example usage:
/// ```dart
/// Future<void> future = Future.value();
/// AsyncResultDart<Unit, Exception> result = await future.toAsyncResult();
/// ```
extension FutureResultExtensionVoid on Future<void> {
  AsyncResultDart<Unit, Exception> toAsyncResult() async {
    try {
      await this;
      return Ok(unit);
    } on Exception catch (e) {
      return Err(e);
    }
  }
}
