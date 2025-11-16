// lib/main.dart

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';
import 'friends_view.dart';
import 'expenses_view.dart';
import 'settle_debt_dialog.dart'; // ¡NUEVO! Importar el diálogo

late Isar isarDB;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  final dir = await getApplicationSupportDirectory();
  
  isarDB = await Isar.open(
    [FriendSchema, ExpenseSchema], 
    directory: dir.path,
  );

  // --- CÓDIGO DE LIMPIEZA ---
  // Déjalo comentado a menos que los datos vuelvan a corromperse
  // await isarDB.writeTxn(() async {
  //   await isarDB.clear(); 
  // });
  // -------------------------

  runApp(
    MultiProvider(
      providers: [
        Provider<Isar>(create: (_) => isarDB), 
        Provider<FriendRepository>(create: (context) => FriendRepository(Isar.getInstance()!)),
        Provider<ExpenseRepository>(create: (context) => ExpenseRepository(Isar.getInstance()!)),
      ],
      child: const SplitWithMeApp(),
    ),
  );
}

class SplitWithMeApp extends StatelessWidget {
  const SplitWithMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPLIT WITH ME',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainTabView(),
    );
  }
}

class MainTabView extends StatelessWidget {
  const MainTabView({super.key});

  static final friendsKey = GlobalKey<FriendsViewState>();
  static final expensesKey = GlobalKey<ExpensesViewState>();

  // ¡NUEVO! Método para mostrar el diálogo de liquidación
  void _showSettleDebtDialog(BuildContext context) async {
    // showDialog necesita el 'context' de MainTabView
    final bool? didSettle = await showDialog(
      context: context,
      builder: (_) => const SettleDebtDialog(),
    );

    // Si el diálogo liquidó una deuda (devolvió true), refrescamos ambas vistas
    if (didSettle == true) {
      friendsKey.currentState?.loadFriends();
      expensesKey.currentState?.loadExpenses(); // Los gastos no cambian, pero es buena práctica
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SPLIT WITH ME'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'FRIENDS'), 
              Tab(text: 'EXPENSES'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FriendsView(key: friendsKey),
            ExpensesView(key: expensesKey),
          ],
        ),
        // ¡ACTUALIZADO! Barra inferior con dos botones
        persistentFooterButtons: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // --- Botón Liquidar Deuda ---
              TextButton(
                onPressed: () => _showSettleDebtDialog(context),
                child: const Text('LIQUIDAR DEUDA'),
              ),
              const SizedBox(width: 8),
              // --- Botón Refresh ---
              TextButton(
                onPressed: () {
                  friendsKey.currentState?.loadFriends();
                  expensesKey.currentState?.loadExpenses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refrescando datos...')),
                  );
                },
                child: const Text('REFRESH'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}