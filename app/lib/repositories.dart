// lib/repositories.dart

import 'package:isar/isar.dart';
import 'models.dart';

// --- REPOSITORIO DE AMIGOS ---
class FriendRepository {
  final Isar isar;

  FriendRepository(this.isar);

  // Guardar/Actualizar Amigo
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
  // ¡ACTUALIZADO! Esta es la lógica de negocio clave que faltaba.
  Future<void> saveExpense(Expense expense) async {
    await isar.writeTxn(() async {
      // 1. Guardar el gasto
      await isar.expenses.put(expense);
      
      // 2. Guardar relaciones (links)
      await expense.payer.save();
      await expense.participants.save();

      // 3. ¡NUEVA LÓGICA DE BALANCE!
      // Recalculamos los balances de todos los amigos implicados
      
      // 3a. Cargar el pagador y los participantes
      await expense.payer.load();
      await expense.participants.load();

      final payer = expense.payer.value;
      final participants = expense.participants.toList();

      if (payer != null && participants.isNotEmpty) {
        
        // 3b. Sumar crédito al pagador
        payer.totalCreditBalance += expense.amount;
        await isar.friends.put(payer); // Guardar amigo pagador actualizado

        // 3c. Sumar débito a cada participante
        final double debitPerParticipant = expense.amount / participants.length;
        
        for (var participant in participants) {
          participant.totalDebitBalance += debitPerParticipant;
          await isar.friends.put(participant); // Guardar amigo participante actualizado
        }
      }
    });
  }


  // Eliminar Gasto (UC-04)
  // ¡ACTUALIZADO! Ahora también re-calcula balances al borrar.
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

      // 3. ¡NUEVA LÓGICA DE BALANCE INVERSO!
      // Restamos los balances que este gasto había generado.
      if (payer != null && participants.isNotEmpty) {
        
        // 3a. Restar crédito al pagador
        payer.totalCreditBalance -= expense.amount;
        await isar.friends.put(payer); 

        // 3b. Restar débito a cada participante
        final double debitPerParticipant = expense.amount / participants.length;
        for (var participant in participants) {
          participant.totalDebitBalance -= debitPerParticipant;
          await isar.friends.put(participant);
        }
      }
    });
  }

  // Obtener todos los Gastos (UC-01)
  Future<List<Expense>> getAllExpenses() async {
    return await isar.expenses.where().findAll();
  }

  // Obtener Detalle del Gasto (UC-05)
  // ¡ACTUALIZADO! Ahora carga las relaciones (links).
  Future<Expense?> getExpenseById(Id id) async {
    final expense = await isar.expenses.get(id);
    if (expense != null) {
      // Cargar las relaciones para la vista de detalle
      await expense.payer.load();
      await expense.participants.load();
    }
    return expense;
  }

  // ¡NUEVO! Para la vista de detalle de Amigo (UC-07)
  // Obtener gastos donde el amigo pagó
  Future<List<Expense>> getExpensesPaidByFriend(Friend friend) async {
    return await isar.expenses
        .filter()
        .payer((q) => q.isarIdEqualTo(friend.isarId))
        .findAll();
  }

  // ¡NUEVO! Para la vista de detalle de Amigo (UC-07)
  // Obtener gastos donde el amigo participó (debe)
  Future<List<Expense>> getExpensesOwedByFriend(Friend friend) async {
    return await isar.expenses
        .filter()
        .participants((q) => q.isarIdEqualTo(friend.isarId))
        .findAll();
  }
}