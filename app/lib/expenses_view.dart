// lib/expenses_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';
import 'expense_form_view.dart'; // Importado para navegación

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  List<Expense> _expensesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<ExpenseRepository>(context, listen: false);
    
    _expensesList = await repo.getAllExpenses();

    // Podemos añadir un gasto de ejemplo si la DB está vacía
    if (_expensesList.isEmpty) {
        // Asumiendo que FriendRepository ha inicializado a los amigos
        final friendRepo = Provider.of<FriendRepository>(context, listen: false);
        final allFriends = await friendRepo.getAllFriends();

        if (allFriends.isNotEmpty) {
            final exampleExpense = Expense(
              description: 'EXPENSE 1', 
              date: DateTime.now(), 
              amount: 50.00,
              numFriends: 2,
              totalCreditBalance: 50.00 // Asumimos que uno pagó todo
            );
            exampleExpense.participants.add(allFriends.first);
            await repo.saveExpense(exampleExpense);
            _expensesList = await repo.getAllExpenses();
        }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_expensesList.isEmpty) {
      return const Center(child: Text('No hay gastos (A1: Sin datos)')); // A1 Alternativa (UC-01)
    }
    
    return Scaffold(
      // Botón "+" para Crear Gasto (UC-02) (Page 8)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseFormView(isEditing: false),
          ),
        ).then((_) => _loadExpenses()), // Recargar la lista al volver
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add), 
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0),
        itemCount: _expensesList.length,
        itemBuilder: (context, index) {
          final expense = _expensesList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${expense.description} - \$${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                
                // Botón "SHOW ALL" (UC-05 - Ver detalle de un gasto)
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ver detalle de ${expense.description} (UC-05)')),
                    );
                  },
                  child: const Text('SHOW ALL'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
