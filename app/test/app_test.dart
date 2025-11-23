import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'dart:math';
import 'package:splitwithfriends/main.dart';
import 'package:splitwithfriends/models.dart';
import 'package:splitwithfriends/repositories.dart';
import 'package:splitwithfriends/friends_view.dart';
import 'package:splitwithfriends/expenses_view.dart';
import 'package:splitwithfriends/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// -------------------------------------------------------------------------
// 1. MOCKS (CLASES FALSAS PARA SIMULAR COMPORTAMIENTO)
// -------------------------------------------------------------------------

class MockIsar implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) async {
    return callback();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Repositorio de Amigos Falso
class MockFriendRepository implements FriendRepository {
  final List<Friend> _friends = [];
  bool shouldThrowError = false; // Interruptor para simular errores de E/S

  MockFriendRepository(Isar isar);

  @override
  Future<List<Friend>> getAllFriends() async {
    if (shouldThrowError) throw Exception("Error de E/S simulado: No se pudo conectar a DB");
    return _friends;
  }

  @override
  Future<void> saveFriend(Friend friend) async {
    if (shouldThrowError) throw Exception("Error de guardado simulado");
    
    if (friend.isarId == Isar.autoIncrement) {
      friend.isarId = _friends.length + 1;
      _friends.add(friend);
    } else {
      final index = _friends.indexWhere((f) => f.isarId == friend.isarId);
      if (index != -1) _friends[index] = friend;
    }
  }

  @override
  Future<void> deleteFriend(Id friendId) async {
    _friends.removeWhere((f) => f.isarId == friendId);
  }

  @override
  Future<Friend?> getFriendById(Id id) async {
    try {
      return _friends.firstWhere((f) => f.isarId == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> settleDebt(Friend payer, Friend receiver, double amount) async {
    // Simulamos la lógica para que el test verifique cambios en los saldos si fuera necesario
    // (Aunque para E2E de UI, basta con ver el mensaje de éxito)
    final p = _friends.firstWhere((f) => f.isarId == payer.isarId);
    final r = _friends.firstWhere((f) => f.isarId == receiver.isarId);
    
    p.totalDebitBalance = max(0, p.totalDebitBalance - amount);
    r.totalCreditBalance = max(0, r.totalCreditBalance - amount);
  }
  
  @override
  Future<void> settleDebts(Friend friend) async {
    final f = _friends.firstWhere((fr) => fr.isarId == friend.isarId);
    f.totalCreditBalance = 0;
    f.totalDebitBalance = 0;
  }
  
  @override
  Isar get isar => MockIsar();
}

// Repositorio de Gastos Falso
class MockExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];
  final MockFriendRepository friendRepo;

  MockExpenseRepository(Isar isar, this.friendRepo);

  @override
  Future<List<Expense>> getAllExpenses() async {
    return _expenses;
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    if (expense.isarId == Isar.autoIncrement) {
      expense.isarId = _expenses.length + 1;
      _expenses.add(expense);
    }
  }

  @override
  Future<void> deleteExpense(Id isarId) async {
    _expenses.removeWhere((e) => e.isarId == isarId);
  }

  @override
  Future<Expense?> getExpenseById(Id id) async {
    return null;
  }
  
  @override
  Future<List<Expense>> getExpensesPaidByFriend(Friend friend) async => [];
  
  @override
  Future<List<Expense>> getExpensesOwedByFriend(Friend friend) async => [];
  
  @override
  Isar get isar => MockIsar();
}

// Helper para inyectar la app con los mocks
Widget createTestApp({
  required FriendRepository friendRepo,
  required ExpenseRepository expenseRepo,
  required Isar isar,
}) {
  return MultiProvider(
    providers: [
      Provider<Isar>.value(value: isar),
      Provider<FriendRepository>.value(value: friendRepo),
      Provider<ExpenseRepository>.value(value: expenseRepo),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en'), Locale('es')],
      locale: Locale('es'),
      home: MainTabView(),
    ),
  );
}

void main() {
  late MockIsar mockIsar;
  late MockFriendRepository mockFriendRepo;
  late MockExpenseRepository mockExpenseRepo;

  setUp(() {
    mockIsar = MockIsar();
    mockFriendRepo = MockFriendRepository(mockIsar);
    mockExpenseRepo = MockExpenseRepository(mockIsar, mockFriendRepo);
  });

  // -----------------------------------------------------------------------
  // TEST GROUP 1: FLUJOS DE USUARIO (HAPPY PATHS)
  // -----------------------------------------------------------------------
  group('E2E Testing - Flujos de Usuario Correctos', () {
    
    testWidgets('Caso de Uso: Añadir Amigo', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        friendRepo: mockFriendRepo,
        expenseRepo: mockExpenseRepo,
        isar: mockIsar,
      ));
      await tester.pumpAndSettle();

      // 1. Abrir diálogo
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Añadir Amigo'), findsOneWidget);

      // 2. Escribir y guardar
      await tester.enterText(find.byType(TextField), 'Pedro');
      await tester.tap(find.text('Añadir'));
      await tester.pumpAndSettle();

      // 3. Verificar
      expect(find.text('Pedro - 0.00€'), findsOneWidget);
    });

    testWidgets('Caso de Uso: Eliminar Amigo (Swipe)', (WidgetTester tester) async {
      // Setup: Añadir amigo previamente
      final amigo = Friend(name: 'Borrable');
      mockFriendRepo._friends.add(amigo);

      await tester.pumpWidget(createTestApp(
        friendRepo: mockFriendRepo,
        expenseRepo: mockExpenseRepo,
        isar: mockIsar,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Borrable - 0.00€'), findsOneWidget);

      // 1. Realizar gesto de Swipe (Deslizar) de derecha a izquierda
      // Buscamos el widget Dismissible por su Key
      await tester.drag(find.byType(Dismissible), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle(); // Esperar animación

      // 2. Verificar que ha desaparecido
      expect(find.text('Borrable - 0.00€'), findsNothing);
      expect(find.text('Amigo eliminado'), findsOneWidget); // Verifica el SnackBar
    });

    testWidgets('Caso de Uso: Crear Gasto', (WidgetTester tester) async {
      final amigo1 = Friend(name: 'Ana');
      final amigo2 = Friend(name: 'Beto');
      mockFriendRepo._friends.addAll([amigo1, amigo2]);

      await tester.pumpWidget(createTestApp(
        friendRepo: mockFriendRepo,
        expenseRepo: mockExpenseRepo,
        isar: mockIsar,
      ));
      await tester.pumpAndSettle();

      // Ir a gastos -> Botón +
      await tester.tap(find.text('GASTOS'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Rellenar form
      await tester.enterText(find.widgetWithText(TextFormField, 'Descripción'), 'Cena');
      await tester.enterText(find.widgetWithText(TextFormField, 'Monto'), '100');
      
      // Dropdown Pagador
      await tester.tap(find.text('Seleccionar pagador'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ana').last); 
      await tester.pumpAndSettle();

      // Checkbox Participante
      await tester.tap(find.text('Beto'));
      await tester.pumpAndSettle();

      // Guardar
      await tester.tap(find.text('CONFIRMAR'));
      await tester.pumpAndSettle();

      expect(find.text('Cena - 100.00€'), findsOneWidget);
    });

    testWidgets('Caso de Uso: Eliminar Gasto (Swipe)', (WidgetTester tester) async {
      final gasto = Expense(description: 'Taxi', date: DateTime.now(), amount: 20);
      mockExpenseRepo._expenses.add(gasto);

      await tester.pumpWidget(createTestApp(
        friendRepo: mockFriendRepo,
        expenseRepo: mockExpenseRepo,
        isar: mockIsar,
      ));
      await tester.pumpAndSettle();

      // Ir a gastos
      await tester.tap(find.text('GASTOS'));
      await tester.pumpAndSettle();

      expect(find.text('Taxi - 20.00€'), findsOneWidget);

      // Swipe para borrar
      await tester.drag(find.byType(Dismissible), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('Taxi - 20.00€'), findsNothing);
      expect(find.text('Gasto eliminado (UC-04)'), findsOneWidget);
    });

    testWidgets('Caso de Uso: Liquidar Deuda', (WidgetTester tester) async {
      // Setup: Dos amigos con deudas simuladas (saldos iniciales)
      final amigo1 = Friend(name: 'Deudor', totalDebitBalance: 50);
      final amigo2 = Friend(name: 'Acreedor', totalCreditBalance: 50);
      mockFriendRepo._friends.addAll([amigo1, amigo2]);

      await tester.pumpWidget(createTestApp(
        friendRepo: mockFriendRepo,
        expenseRepo: mockExpenseRepo,
        isar: mockIsar,
      ));
      await tester.pumpAndSettle();

      // 1. Abrir diálogo Liquidar
      await tester.tap(find.text('LIQUIDAR DEUDA'));
      await tester.pumpAndSettle();

      expect(find.text('Liquidar Deuda'), findsOneWidget);

      // 2. Seleccionar Pagador
      await tester.tap(find.text('Quién paga...'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deudor').last);
      await tester.pumpAndSettle();

      // 3. Seleccionar Receptor
      await tester.tap(find.text('Quién recibe...'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acreedor').last);
      await tester.pumpAndSettle();

      // 4. Monto
      await tester.enterText(find.widgetWithText(TextFormField, 'Monto'), '50');

      // 5. Confirmar
      await tester.tap(find.text('LIQUIDAR'));
      await tester.pumpAndSettle();

      // 6. Verificar mensaje de éxito
      expect(find.text('Deuda liquidada: 50.00€'), findsOneWidget);
    });
  });

  // -----------------------------------------------------------------------
  // TEST GROUP 2: ERRORES DE USUARIO (VALIDACIONES)
  // -----------------------------------------------------------------------
  group('Tests de Errores de Usuario (Validaciones)', () {
    
    testWidgets('Error: Crear gasto vacío', (WidgetTester tester) async {
      mockFriendRepo._friends.add(Friend(name: 'Test'));

      await tester.pumpWidget(createTestApp(
        friendRepo: mockFriendRepo,
        expenseRepo: mockExpenseRepo,
        isar: mockIsar,
      ));
      
      await tester.tap(find.text('GASTOS'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Intentar guardar sin datos
      await tester.tap(find.text('CONFIRMAR'));
      await tester.pumpAndSettle();

      // Seguimos en el formulario
      expect(find.text('CREAR GASTO'), findsOneWidget);
      expect(find.text('Error'), findsWidgets); // Mensajes de validación
    });

    testWidgets('Error: Liquidar deuda incompleta', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        friendRepo: mockFriendRepo,
        expenseRepo: mockExpenseRepo,
        isar: mockIsar,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('LIQUIDAR DEUDA'));
      await tester.pumpAndSettle();

      // Intentar liquidar sin seleccionar a nadie
      await tester.tap(find.text('LIQUIDAR'));
      await tester.pumpAndSettle();

      // Verificar que seguimos en el diálogo (no se cerró)
      expect(find.text('Liquidar Deuda'), findsOneWidget);
      // Deberían aparecer mensajes de error
      expect(find.text('Selecciona un pagador'), findsOneWidget);
    });
  });

  // -----------------------------------------------------------------------
  // TEST GROUP 3: ERRORES DE E/S (SIMULADOS)
  // -----------------------------------------------------------------------
  group('Tests de Errores de E/S (Simulados)', () {
    
    testWidgets('Manejo de error al cargar amigos', (WidgetTester tester) async {
      // Configurar el mock para fallar
      mockFriendRepo.shouldThrowError = true;

      await tester.pumpWidget(createTestApp(
        friendRepo: mockFriendRepo,
        expenseRepo: mockExpenseRepo,
        isar: mockIsar,
      ));
      
      await tester.pumpAndSettle();

      // Verificar feedback visual
      expect(find.text('No se pudo recuperar la lista de amigos'), findsOneWidget);
    });

    testWidgets('Manejo de error al guardar amigo', (WidgetTester tester) async {
      // Primero cargamos la app bien
      await tester.pumpWidget(createTestApp(
        friendRepo: mockFriendRepo,
        expenseRepo: mockExpenseRepo,
        isar: mockIsar,
      ));
      await tester.pumpAndSettle();

      // Ahora activamos el error para la acción de guardar
      mockFriendRepo.shouldThrowError = true;

      // Abrir diálogo
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Intentar guardar
      await tester.enterText(find.byType(TextField), 'Nuevo');
      await tester.tap(find.text('Añadir'));
      await tester.pumpAndSettle();

      // Verificar mensaje de error en UI
      expect(find.text('No se pudo añadir al amigo Nuevo'), findsOneWidget);
    });
  });
}