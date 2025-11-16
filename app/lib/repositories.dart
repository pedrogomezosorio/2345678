// lib/repositories.dart

import 'package:isar/isar.dart';
import 'models.dart';

// --- REPOSITORIO DE AMIGOS ---
class FriendRepository {
  final Isar isar;

  FriendRepository(this.isar);

  Future<void> saveFriend(Friend friend) async {
    await isar.writeTxn(() async {
      await isar.friends.put(friend);
    });
  }

  Future<void> deleteFriend(Id friendId) async {
    await isar.writeTxn(() async {
      await isar.friends.delete(friendId);
    });
  }

  Future<List<Friend>> getAllFriends() async {
    return await isar.friends.where().findAll();
  }

  Future<Friend?> getFriendById(Id id) async {
    return await isar.friends.get(id);
  }
}

// --- REPOSITORIO DE GASTOS ---
class ExpenseRepository {
  final Isar isar;

  ExpenseRepository(this.isar);

  // ¡LÓGICA CORREGIDA PARA CREAR/ACTUALIZAR GASTO!
  Future<void> saveExpense(Expense expense) async {
    await isar.writeTxn(() async {
      // 1. Guardar el gasto y sus relaciones
      await isar.expenses.put(expense);
      await expense.payer.save();
      await expense.participants.save();

      // 2. Cargar relaciones
      await expense.payer.load();
      await expense.participants.load();

      final payer = expense.payer.value;
      final participants = expense.participants.toList();

      if (payer == null || participants.isEmpty) return;

      // --- ¡LÓGICA DE ACTUALIZACIÓN CORREGIDA! ---
      // Usamos un Map para asegurarnos de que solo tenemos UNA instancia
      // de cada amigo y evitar sobrescribir los cambios.
      Map<Id, Friend> friendsToUpdate = {};

      // 3. Añadir al pagador al mapa
      friendsToUpdate[payer.isarId] = payer;
      
      // 4. Añadir a los participantes al mapa (si no están ya)
      for (var participant in participants) {
        if (!friendsToUpdate.containsKey(participant.isarId)) {
          friendsToUpdate[participant.isarId] = participant;
        }
      }

      // 5. Calcular y aplicar los cambios en el Map
      final double debitPerParticipant = expense.amount / participants.length;

      // 5a. Aplicar Crédito al pagador
      // (Usamos '!' porque sabemos que está en el mapa)
      friendsToUpdate[payer.isarId]!.totalCreditBalance += expense.amount;

      // 5b. Aplicar Débito a todos los participantes
      for (var participant in participants) {
        friendsToUpdate[participant.isarId]!.totalDebitBalance += debitPerParticipant;
      }

      // 6. Guardar TODOS los amigos actualizados en la BBDD
      await isar.friends.putAll(friendsToUpdate.values.toList());
    });
  }


  // ¡LÓGICA CORREGIDA PARA ELIMINAR GASTO! (UC-04)
  Future<void> deleteExpense(Id isarId) async {
    await isar.writeTxn(() async {
      // 1. Cargar el gasto y sus relaciones ANTES de borrarlo
      final expense = await isar.expenses.get(isarId);
      if (expense == null) return;
      
      await expense.payer.load();
      await expense.participants.load();
      final payer = expense.payer.value;
      final participants = expense.participants.toList();

      // 2. Borrar el gasto
      await isar.expenses.delete(isarId);

      if (payer == null || participants.isEmpty) return;
      
      // --- ¡LÓGICA DE ACTUALIZACIÓN INVERSA CORREGIDA! ---
      Map<Id, Friend> friendsToUpdate = {};

      // 3. Añadir al pagador y participantes al map
      friendsToUpdate[payer.isarId] = payer;
      for (var participant in participants) {
        if (!friendsToUpdate.containsKey(participant.isarId)) {
          friendsToUpdate[participant.isarId] = participant;
        }
      }

      // 4. Calcular y aplicar los cambios en el Map
      final double debitPerParticipant = expense.amount / participants.length;

      // 4a. Restar Crédito al pagador
      friendsToUpdate[payer.isarId]!.totalCreditBalance -= expense.amount;

      // 4b. Restar Débito a todos los participantes
      for (var participant in participants) {
        friendsToUpdate[participant.isarId]!.totalDebitBalance -= debitPerParticipant;
      }

      // 5. Guardar todos los amigos actualizados
      await isar.friends.putAll(friendsToUpdate.values.toList());
    });
  }

  // --- MÉTODOS DE LECTURA (sin cambios) ---

  Future<List<Expense>> getAllExpenses() async {
    return await isar.expenses.where().findAll();
  }

  Future<Expense?> getExpenseById(Id id) async {
    final expense = await isar.expenses.get(id);
    if (expense != null) {
      await expense.payer.load();
      await expense.participants.load();
    }
    return expense;
  }

  Future<List<Expense>> getExpensesPaidByFriend(Friend friend) async {
    return await isar.expenses
        .filter()
        .payer((q) => q.isarIdEqualTo(friend.isarId))
        .findAll();
  }

  Future<List<Expense>> getExpensesOwedByFriend(Friend friend) async {
    return await isar.expenses
        .filter()
        .participants((q) => q.isarIdEqualTo(friend.isarId))
        .findAll();
  }
}