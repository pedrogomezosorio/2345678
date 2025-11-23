import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitwithfriends/models.dart';
import 'package:splitwithfriends/repositories.dart';
import 'l10n/app_localizations.dart';

class FriendDetailsView extends StatefulWidget {
  final Friend friend;
  
  const FriendDetailsView({super.key, required this.friend});

  @override
  State<FriendDetailsView> createState() => _FriendDetailsViewState();
}

class _FriendDetailsViewState extends State<FriendDetailsView> {
  late Future<List<Expense>> _expensesFuture;
  late Friend _friend;

  @override
  void initState() {
    super.initState();
    _friend = widget.friend;
    _loadExpenses();
  }

  void _loadExpenses() {
    _expensesFuture = Provider.of<ExpenseRepository>(context, listen: false)
        .getExpensesOwedByFriend(_friend); // Usar método del repo adecuado
        // Nota: Si usaste getExpensesForFriend en el repo, cámbialo aquí.
    setState(() {});
  }
  
  Future<void> _settleDebts() async {
    final repo = Provider.of<FriendRepository>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    final bool didConfirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogSettleTitle),
        content: Text('Confirm ${l10n.btnLiquidar}?'), // Simplificado
        actions: [
          TextButton(
            child: Text(l10n.btnCancel),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text(l10n.btnLiquidar, style: const TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    ) ?? false;

    if (didConfirm) {
      await repo.settleDebts(_friend);
      final updatedFriend = await repo.getFriendById(_friend.isarId);
      if (updatedFriend != null) {
        setState(() => _friend = updatedFriend);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.msgDebtSettled)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final netBalance = _friend.netBalance;
    final color = netBalance < 0 ? Colors.red : (netBalance > 0 ? Colors.green : Colors.black);

    return Scaffold(
      appBar: AppBar(title: Text(_friend.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.headerBalance(_friend.name), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            InfoCard(
              title: l10n.labelNetBalance,
              amount: netBalance,
              color: color,
              currency: l10n.currencySymbol,
            ),
            InfoCard(
              title: l10n.labelCredit,
              amount: _friend.totalCreditBalance,
              color: Colors.green,
              currency: l10n.currencySymbol,
            ),
            InfoCard(
              title: l10n.labelDebit,
              amount: _friend.totalDebitBalance,
              color: Colors.red,
              currency: l10n.currencySymbol,
            ),
            
            if (netBalance != 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _settleDebts,
                    child: Text(l10n.btnLiquidar),
                  ),
                ),
              ),

            const Divider(height: 40),

            Text(l10n.headerExpensesList, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Expense>>(
                future: _expensesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final expenses = snapshot.data ?? [];
                  if (expenses.isEmpty) {
                    return Center(child: Text(l10n.msgNoExpensesFriend));
                  }

                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final amountPerParticipant = expense.amount / expense.participants.length;
                      
                      return ListTile(
                        title: Text(expense.description),
                        subtitle: Text('${l10n.labelPaidBy}: ${expense.payer.value?.name ?? 'N/A'}'),
                        trailing: Text(
                          '${l10n.currencySymbol}${amountPerParticipant.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final String currency;

  const InfoCard({
    super.key, 
    required this.title, 
    required this.amount, 
    this.color = Colors.black,
    this.currency = '\$',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              '$currency${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}