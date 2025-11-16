// lib/expense_details_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';

class ExpenseDetailsView extends StatefulWidget {
  final Expense expense; // Recibimos el gasto con los datos básicos

  const ExpenseDetailsView({super.key, required this.expense});

  @override
  State<ExpenseDetailsView> createState() => _ExpenseDetailsViewState();
}

class _ExpenseDetailsViewState extends State<ExpenseDetailsView> {
  Expense? _fullExpense;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullExpense();
  }

  // Cargamos la versión completa del gasto (con links)
  Future<void> _loadFullExpense() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final repo = Provider.of<ExpenseRepository>(context, listen: false);
    _fullExpense = await repo.getExpenseById(widget.expense.isarId);
    
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el gasto completo si está cargado, si no, el básico
    final expense = _fullExpense ?? widget.expense;
    final payer = _fullExpense?.payer.value;
    final participants = _fullExpense?.participants.toList() ?? [];
    final debitPerParticipant = participants.isNotEmpty ? (expense.amount / participants.length) : 0;

    return Scaffold(
      appBar: AppBar(title: Text(expense.description)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- Tarjeta de Resumen (UC-05) ---
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Pagado por: ${payer?.name ?? "..."}',
                          style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fecha: ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Lista de Participantes (UC-05) ---
                Text(
                  'Participantes (${participants.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (participants.isEmpty)
                  const ListTile(title: Text('No hay participantes cargados...'))
                else
                  ...participants.map((friend) => ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(friend.name),
                        trailing: Text(
                          'Debe \$${debitPerParticipant.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )),
              ],
            ),
    );
  }
}