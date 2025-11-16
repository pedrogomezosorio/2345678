// lib/friend_details_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';

class FriendDetailsView extends StatefulWidget {
  final Friend friend;

  const FriendDetailsView({super.key, required this.friend});

  @override
  State<FriendDetailsView> createState() => _FriendDetailsViewState();
}

class _FriendDetailsViewState extends State<FriendDetailsView> {
  List<Expense> _expensesPaid = [];
  List<Expense> _expensesOwed = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final repo = Provider.of<ExpenseRepository>(context, listen: false);
    _expensesPaid = await repo.getExpensesPaidByFriend(widget.friend);
    _expensesOwed = await repo.getExpensesOwedByFriend(widget.friend);
    
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final netBalance = widget.friend.totalCreditBalance - widget.friend.totalDebitBalance;
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.friend.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- Tarjeta de Balance General (UC-07) ---
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Balance Neto', style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          '\$${netBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: netBalance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBalanceColumn('Total Pagado', widget.friend.totalCreditBalance, Colors.green),
                            _buildBalanceColumn('Total Debe', widget.friend.totalDebitBalance, Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Lista de Gastos Pagados ---
                Text('Gastos Pagados por ${widget.friend.name}', style: Theme.of(context).textTheme.titleMedium),
                if (_expensesPaid.isEmpty) const Text('Ninguno'),
                ..._expensesPaid.map((e) => ListTile(
                      title: Text(e.description),
                      trailing: Text('+\$${e.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                    )),
                
                const SizedBox(height: 24),

                // --- Lista de Gastos donde Debe ---
                Text('Gastos donde ${widget.friend.name} Debe', style: Theme.of(context).textTheme.titleMedium),
                if (_expensesOwed.isEmpty) const Text('Ninguno'),
                ..._expensesOwed.map((e) {
                  final amountOwed = e.amount / e.participants.length; // Asume división equitativa
                  return ListTile(
                    title: Text(e.description),
                    trailing: Text('-\$${amountOwed.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildBalanceColumn(String title, double value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}