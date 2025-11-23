// lib/tablet_layout.dart

import 'package:flutter/material.dart';
import 'package:splitwithfriends/expenses_view.dart';
import 'package:splitwithfriends/friends_view.dart';
import 'package:splitwithfriends/main.dart'; // Para las GlobalKeys
import 'package:splitwithfriends/settle_debt_dialog.dart';

class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  void _showSettleDebtDialog(BuildContext context) async {
    final bool? didSettle = await showDialog(
      context: context,
      builder: (_) => const SettleDebtDialog(),
    );

    if (didSettle == true) {
      MainTabView.friendsKey.currentState?.loadFriends();
      MainTabView.expensesKey.currentState?.loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SPLIT WITH ME',
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold), 
        ),
      ),
      body: Row(
        children: [
          // --- Columna Izquierda (Amigos) ---
          Expanded(
            flex: 1,
            child: ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0), 
                    child: Text(
                      'AMIGOS',
                      style: Theme.of(context).textTheme.headlineMedium, 
                    ),
                  ),
                  
                  // ¡NUEVO! Línea divisoria para diferenciar
                  const Divider(height: 1, thickness: 1), 
                  
                  Expanded( 
                    child: FriendsView(key: MainTabView.friendsKey),
                  ),
                ],
              ),
            ),
          ),
          
          // --- Divisor Vertical ---
          const VerticalDivider(width: 1, thickness: 1),

          // --- Columna Derecha (Gastos) ---
          Expanded(
            flex: 1,
            child: ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0), 
                    child: Text(
                      'GASTOS',
                      style: Theme.of(context).textTheme.headlineMedium, 
                    ),
                  ),
                  
                  // ¡NUEVO! Línea divisoria para diferenciar
                  const Divider(height: 1, thickness: 1), 
                  
                  Expanded( 
                    child: ExpensesView(key: MainTabView.expensesKey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showSettleDebtDialog(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16), 
                ),
                child: const Text(
                  'LIQUIDAR DEUDA',
                  style: TextStyle(fontSize: 20), 
                ),
              ),
              const SizedBox(width: 20), 
              TextButton(
                onPressed: () {
                  MainTabView.friendsKey.currentState?.loadFriends();
                  MainTabView.expensesKey.currentState?.loadExpenses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refrescando datos...')),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16), 
                ),
                child: const Text(
                  'REFRESH',
                  style: TextStyle(fontSize: 20), 
                ),
              ),
            ],
          ),
        ],
    );
  }
}