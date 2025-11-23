import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/app_localizations.dart';

import 'models.dart';
import 'repositories.dart';
import 'expense_form_view.dart';
import 'expense_details_view.dart';
import 'main.dart';
import 'friends_view.dart';

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => ExpensesViewState();
}

class ExpensesViewState extends State<ExpensesView> {
  List<Expense> _expensesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadExpenses();
    });
  }

  Future<void> loadExpenses() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final repo = Provider.of<ExpenseRepository>(context, listen: false);
    _expensesList = await repo.getAllExpenses();

    if (_expensesList.isEmpty) {
      final friendRepo = Provider.of<FriendRepository>(context, listen: false);
      final allFriends = await friendRepo.getAllFriends();

      if (allFriends.length >= 2) {
        final exampleExpense = Expense(
          description: 'Gasto de Ejemplo',
          date: DateTime.now(),
          amount: 50.00,
        );
        exampleExpense.payer.value = allFriends[0];
        exampleExpense.participants.addAll([allFriends[0], allFriends[1]]);

        await repo.saveExpense(exampleExpense);
        _expensesList = await repo.getAllExpenses();
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _deleteExpense(Id expenseId) async {
    if (!mounted) return;
    final repo = Provider.of<ExpenseRepository>(context, listen: false);
    await repo.deleteExpense(expenseId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.expenseDeleted)),
    );

    MainTabView.friendsKey.currentState?.loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // AQUÍ FALTABA EL ONPRESSED, YA ESTÁ AÑADIDO:
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseFormView(isEditing: false),
          ),
        ).then((didSave) {
          if (didSave == true) {
            loadExpenses();
            MainTabView.friendsKey.currentState?.loadFriends();
          }
        }),
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),

      body: _expensesList.isEmpty
          ? Center(child: Text(l10n.noExpenses))
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8.0),
        itemCount: _expensesList.length,
        itemBuilder: (context, index) {
          final expense = _expensesList[index];

          return Dismissible(
            key: Key(expense.isarId.toString()), // AQUÍ FALTABA LA KEY
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteExpense(expense.isarId);
              setState(() {
                _expensesList.removeAt(index);
              });
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${expense.description} - ${l10n.currencySymbol}${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpenseDetailsView(expense: expense),
                        ),
                      );
                    },
                    child: Text(l10n.showAll),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}