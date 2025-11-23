import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';
import 'expense_form_view.dart';
import 'expense_details_view.dart';
import 'main.dart';
import 'l10n/app_localizations.dart';

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
    // Cargar después del build para tener contexto seguro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadExpenses();
    });
  }

  Future<void> loadExpenses() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final repo = Provider.of<ExpenseRepository>(context, listen: false);
      _expensesList = await repo.getAllExpenses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar gastos')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExpense(Id expenseId) async {
    if (!mounted) return;
    try {
      final repo = Provider.of<ExpenseRepository>(context, listen: false);
      await repo.deleteExpense(expenseId);

      setState(() {
        _expensesList.removeWhere((e) => e.isarId == expenseId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.expenseDeleted)),
        ).closed.then((_) {
           MainTabView.friendsKey.currentState?.loadFriends();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar gasto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExpenseFormView(isEditing: false),
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
      // CAMBIO AQUÍ: Se cambió de 'endTop' a 'endFloat' para bajar el botón
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _expensesList.isEmpty
          ? Center(child: Text(l10n.noExpenses))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: _expensesList.length,
              itemBuilder: (context, index) {
                final expense = _expensesList[index];
                final payerName = expense.payer.value?.name ?? 'N/A';

                return Dismissible(
                  key: Key(expense.isarId.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteExpense(expense.isarId);
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${expense.description} - ${expense.amount.toStringAsFixed(2)}${l10n.currencySymbol}',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                              Text(
                                '${l10n.labelPaidBy}: $payerName',
                                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                              ),
                            ],
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