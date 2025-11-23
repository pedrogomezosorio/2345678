// lib/utils/result.dart

import 'package:flutter/foundation.dart';

/// Clase base para manejar resultados de operaciones (éxito o error).
@immutable
sealed class Result<T> {}

/// Representa una operación exitosa que devuelve un valor [value] de tipo [T].
final class Ok<T> extends Result<T> {
  final T value;
  // Corrección: Eliminado 'const'
  Ok(this.value);
}

/// Representa una operación fallida que devuelve un objeto [error] de tipo [Exception].
final class Error<T> extends Result<T> {
  final Exception error;
  // Corrección: Eliminado 'const'
  Error(this.error);
}
