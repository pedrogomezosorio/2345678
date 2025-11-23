// lib/repositories.dart

import 'dart:math'; // ¡NUEVO! Necesario para la función max()
import 'package:isar/isar.dart';
import 'models.dart';

// --- REPOSITORIO DE AMIGOS ---
class FriendRepository {
  final Isar isar;

  FriendRepository(this.isar);

  // ¡NUEVO! Método para liquidar deudas
  Future<void> settleDebt(Friend payer, Friend receiver, double amount) async {
    await isar.writeTxn(() async {
      // El 'Pagador' reduce su DEBITO (lo que debe)
      payer.totalDebitBalance = max(0, payer.totalDebitBalance - amount);
      
      // El 'Receptor' reduce su CRÉDITO (lo que se le debe)
      receiver.totalCreditBalance = max(0, receiver.totalCreditBalance - amount);

      // Guardamos ambos amigos actualizados
      await isar.friends.putAll([payer, receiver]);
    });
  }


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

  // Lógica de Guardar Gasto (Corregida)
  Future<void> saveExpense(Expense expense) async {
    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
      await expense.payer.save();
      await expense.participants.save();

      await expense.payer.load();
      await expense.participants.load();

      final payer = expense.payer.value;
      final participants = expense.participants.toList();
      if (payer == null || participants.isEmpty) return;

      Map<Id, Friend> friendsToUpdate = {};
      friendsToUpdate[payer.isarId] = payer;
      for (var participant in participants) {
        if (!friendsToUpdate.containsKey(participant.isarId)) {
          friendsToUpdate[participant.isarId] = participant;
        }
      }

      final double debitPerParticipant = expense.amount / participants.length;
      friendsToUpdate[payer.isarId]!.totalCreditBalance += expense.amount;
      for (var participant in participants) {
        friendsToUpdate[participant.isarId]!.totalDebitBalance += debitPerParticipant;
      }
      await isar.friends.putAll(friendsToUpdate.values.toList());
    });
  }

  // Lógica de Borrar Gasto (Corregida)
  Future<void> deleteExpense(Id isarId) async {
    await isar.writeTxn(() async {
      final expense = await isar.expenses.get(isarId);
      if (expense == null) return;
      
      await expense.payer.load();
      await expense.participants.load();
      final payer = expense.payer.value;
      final participants = expense.participants.toList();

      await isar.expenses.delete(isarId);
      if (payer == null || participants.isEmpty) return;
      
      Map<Id, Friend> friendsToUpdate = {};
      friendsToUpdate[payer.isarId] = payer;
      for (var participant in participants) {
        if (!friendsToUpdate.containsKey(participant.isarId)) {
          friendsToUpdate[participant.isarId] = participant;
        }
      }

      final double debitPerParticipant = expense.amount / participants.length;
      friendsToUpdate[payer.isarId]!.totalCreditBalance -= expense.amount;
      for (var participant in participants) {
        friendsToUpdate[participant.isarId]!.totalDebitBalance -= debitPerParticipant;
      }
      await isar.friends.putAll(friendsToUpdate.values.toList());
    });
  }

  // --- Métodos de Lectura (sin cambios) ---
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