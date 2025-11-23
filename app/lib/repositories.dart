import 'dart:math';
import 'package:isar/isar.dart';
import 'models.dart';

class FriendRepository {
  final Isar isar;

  FriendRepository(this.isar);

  Future<void> settleDebt(Friend payer, Friend receiver, double amount) async {
    await isar.writeTxn(() async {
      payer.totalDebitBalance = max(0, payer.totalDebitBalance - amount);
      receiver.totalCreditBalance = max(0, receiver.totalCreditBalance - amount);
      await isar.friends.putAll([payer, receiver]);
    });
  }

  Future<void> settleDebts(Friend friend) async {
    await isar.writeTxn(() async {
      friend.totalCreditBalance = 0.0;
      friend.totalDebitBalance = 0.0;
      await isar.friends.put(friend);
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

class ExpenseRepository {
  final Isar isar;

  ExpenseRepository(this.isar);

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

      payer.totalCreditBalance += expense.amount;
      await isar.friends.put(payer);

      final double debitPerParticipant = expense.amount / participants.length;
      for (var participant in participants) {
        participant.totalDebitBalance += debitPerParticipant;
        await isar.friends.put(participant);
      }
    });
  }

  Future<void> deleteExpense(Id isarId) async {
    await isar.writeTxn(() async {
      final expense = await isar.expenses.get(isarId);
      if (expense == null) return;
      
      await expense.payer.load();
      await expense.participants.load();
      final payer = expense.payer.value;
      final participants = expense.participants.toList();

      await isar.expenses.delete(isarId);

      if (payer != null && participants.isNotEmpty) {
        payer.totalCreditBalance = max(0, payer.totalCreditBalance - expense.amount);
        await isar.friends.put(payer);

        final double debitPerParticipant = expense.amount / participants.length;
        for (var participant in participants) {
          participant.totalDebitBalance = max(0, participant.totalDebitBalance - debitPerParticipant);
          await isar.friends.put(participant);
        }
      }
    });
  }

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