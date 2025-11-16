// lib/expenses_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';
import 'expense_form_view.dart';
import 'expense_details_view.dart'; // Importar vista detalle
import 'main.dart';                 // Importar para la GlobalKey
import 'friends_view.dart';           // Importar para el tipo de la GlobalKey

class ExpensesView extends StatefulWidget {
  // Se requiere una Key para que el botón REFRESH global funcione
  const ExpensesView({super.key});

  @override
  // El nombre de la clase de estado ahora es público
  State<ExpensesView> createState() => ExpensesViewState();
}

// La clase de estado ahora es pública 'ExpensesViewState'
class ExpensesViewState extends State<ExpensesView> {
  List<Expense> _expensesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadExpenses(); // Renombrado de _loadExpenses
    });
  }

  // Método ahora público para ser llamado por el REFRESH global
  Future<void> loadExpenses() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final repo = Provider.of<ExpenseRepository>(context, listen: false);
    _expensesList = await repo.getAllExpenses();

    // Lógica para añadir un gasto de ejemplo si está vacío
    // ¡ACTUALIZADA para usar la nueva lógica de 'payer' y 'balances'!
    if (_expensesList.isEmpty) {
        final friendRepo = Provider.of<FriendRepository>(context, listen: false);
        final allFriends = await friendRepo.getAllFriends();

        if (allFriends.length >= 2) { // Necesitamos al menos 2 amigos para el ejemplo
            final exampleExpense = Expense(
              description: 'Gasto de Ejemplo', 
              date: DateTime.now(), 
              amount: 50.00,
            );
            // El primer amigo paga
            exampleExpense.payer.value = allFriends[0];
            // Participan los dos primeros amigos
            exampleExpense.participants.addAll([allFriends[0], allFriends[1]]);
            
            // saveExpense AHORA actualiza los balances automáticamente
            await repo.saveExpense(exampleExpense); 
            _expensesList = await repo.getAllExpenses();
        }
    }
    
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
   
    return Scaffold(
      // Botón "+" para Crear Gasto (UC-02)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseFormView(isEditing: false),
          ),
        ).then((didSave) {
          // ¡ACTUALIZADO! Si el formulario guardó (devolvió true)...
          if (didSave == true) {
            // Recargamos los gastos (esta vista)
            loadExpenses();
            // ¡Y recargamos los amigos (para ver el balance actualizado)!
            MainTabView.friendsKey.currentState?.loadFriends();
          }
        }), 
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add), 
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      
      body: _expensesList.isEmpty
          ? const Center(child: Text('No hay gastos (A1: Sin datos)'))
          : ListView.builder(
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
                      
                      // ¡ACTUALIZADO! Botón "SHOW ALL" (UC-05)
                      OutlinedButton(
                        onPressed: () {
                          // ¡NUEVA LÓGICA! Navegar a la vista de detalle
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpenseDetailsView(expense: expense),
                            ),
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