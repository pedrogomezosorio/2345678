// lib/utils/command.dart

import 'package:flutter/material.dart';

/// Comando sin argumentos y con valor de retorno [R].
class Command0<R> {
  final Future<R> Function() _action;
  final ValueNotifier<bool> isExecuting = ValueNotifier(false);
  
  Command0(this._action);

  Future<R> execute() async {
    if (isExecuting.value) {
      throw Exception("Command is already executing.");
    }
    isExecuting.value = true;
    try {
      // Corrección: Devolver el resultado de la acción
      return await _action();
    } finally {
      isExecuting.value = false;
    }
  }
}

/// Comando con 1 argumento [T] y con valor de retorno [R].
class Command1<R, T> {
  final Future<R> Function(T) _action;
  final ValueNotifier<bool> isExecuting = ValueNotifier(false);
  
  Command1(this._action);

  Future<R> execute(T arg) async {
    if (isExecuting.value) {
      throw Exception("Command is already executing.");
    }
    isExecuting.value = true;
    try {
      // Corrección: Devolver el resultado de la acción
      return await _action(arg);
    } finally {
      isExecuting.value = false;
    }
  }
}

/// Comando con 3 argumentos [T1, T2, T3] y con un valor de retorno [R].
class Command3<R, T1, T2, T3> {
  final Future<R> Function(T1, T2, T3) _action;
  final ValueNotifier<bool> isExecuting = ValueNotifier(false);
  
  Command3(this._action);

  Future<R> execute(T1 arg1, T2 arg2, T3 arg3) async {
    if (isExecuting.value) {
      throw Exception("Command is already executing.");
    }
    isExecuting.value = true;
    try {
      return await _action(arg1, arg2, arg3);
    } finally {
      isExecuting.value = false;
    }
  }
}
