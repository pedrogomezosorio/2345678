// lib/repositories.dart

import 'package:isar/isar.dart';
import 'models.dart';

// --- REPOSITORIO DE AMIGOS ---
class FriendRepository {
  final Isar isar;

  FriendRepository(this.isar);

  // Guardar/Actualizar Amigo (Para simular la creación de datos iniciales)
  Future<void> saveFriend(Friend friend) async {
    await isar.writeTxn(() async {
      await isar.friends.put(friend);
    });
  }

  // Obtener todos los Amigos (UC-06)
  Future<List<Friend>> getAllFriends() async {
    return await isar.friends.where().findAll();
  }

  // Obtener un Amigo por ID (UC-07)
  Future<Friend?> getFriendById(Id id) async {
    return await isar.friends.get(id);
  }
}

// --- REPOSITORIO DE GASTOS ---
class ExpenseRepository {
  final Isar isar;

  ExpenseRepository(this.isar);

  // Crear/Actualizar Gasto (UC-02, UC-03)
  Future<void> saveExpense(Expense expense) async {
    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
      // Las relaciones (links) deben ser guardadas por separado
      await expense.participants.save();
    });
  }

  // Eliminar Gasto (UC-04)
  Future<void> deleteExpense(Id isarId) async {
    await isar.writeTxn(() async {
      await isar.expenses.delete(isarId);
    });
  }

  // Obtener todos los Gastos (UC-01)
  Future<List<Expense>> getAllExpenses() async {
    return await isar.expenses.where().findAll();
  }

  // Obtener Detalle del Gasto (UC-05)
  Future<Expense?> getExpenseById(Id id) async {
    // Nota: Para cargar las relaciones (participants), necesitarías un .load() 
    // pero para simplicidad, devolvemos el objeto principal.
    return await isar.expenses.get(id);
  }
}
