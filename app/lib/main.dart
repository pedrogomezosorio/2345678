// lib/main.dart

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';
import 'friends_view.dart';
import 'expenses_view.dart';

late Isar isarDB;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  final dir = await getApplicationSupportDirectory();
  
  isarDB = await Isar.open(
    [FriendSchema, ExpenseSchema], 
    directory: dir.path,
  );

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

  // ¡ACTUALIZADO! Keys ahora públicas (sin guion bajo)
  static final friendsKey = GlobalKey<FriendsViewState>();
  static final expensesKey = GlobalKey<ExpensesViewState>();

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
            // ¡ACTUALIZADO! Usando las keys públicas
            FriendsView(key: friendsKey),
            ExpensesView(key: expensesKey),
          ],
        ),
        persistentFooterButtons: [
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                // ¡ACTUALIZADO! Usando las keys públicas
                friendsKey.currentState?.loadFriends();
                expensesKey.currentState?.loadExpenses();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refrescando datos...')),
                );
              },
              child: const Text('REFRESH'),
            ),
          ),
        ],
      ),
    );
  }
}