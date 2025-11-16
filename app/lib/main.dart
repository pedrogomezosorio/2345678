// lib/main.dart

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';
import 'friends_view.dart';
import 'expenses_view.dart';
// Asegúrate de que los archivos 'friends_viewmodel.dart', 'services.dart', y 'utils/' existen.

late Isar isarDB;

void main() async {
  // Asegura que los widgets estén inicializados antes de abrir Isar
  WidgetsFlutterBinding.ensureInitialized(); 

  // 1. Obtiene la ruta donde se almacenará la DB local
  final dir = await getApplicationSupportDirectory();
  
  // 2. Abre la instancia de Isar (FriendSchema y ExpenseSchema son generados)
  isarDB = await Isar.open(
    [FriendSchema, ExpenseSchema], 
    directory: dir.path,
    // inspector: true, // Útil para depuración si lo tienes instalado
  );

  runApp(
    MultiProvider(
      providers: [
        // Proporciona la instancia de Isar
        Provider<Isar>(create: (_) => isarDB), 
        // Proporciona los repositorios que necesitan la instancia de Isar
        Provider<FriendRepository>(create: (context) => FriendRepository(Isar.getInstance()!)),
        Provider<ExpenseRepository>(create: (context) => ExpenseRepository(Isar.getInstance()!)),
        // Puedes agregar aquí los ViewModels si usan Provider
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

  @override
  Widget build(BuildContext context) {
    // Page 5 - Interfaz principal con dos secciones FRIENDS / EXPENSES
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
        body: const TabBarView(
          children: [
            FriendsView(),
            ExpensesView(),
          ],
        ),
        // Botón global de REFRESH (Page 6/8)
        persistentFooterButtons: [
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                // Lógica para actualizar las vistas (ej. llamar a los ViewModels)
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
