import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models.dart';
import 'repositories.dart';
import 'friends_view.dart';
import 'expenses_view.dart';
import 'settle_debt_dialog.dart';

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
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // Inglés
        Locale('es'), // Español
      ],
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
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

  void _showSettleDebtDialog(BuildContext context) async {
    final bool? didSettle = await showDialog(
      context: context,
      builder: (_) => const SettleDebtDialog(),
    );

    if (didSettle == true) {
      friendsKey.currentState?.loadFriends();
      expensesKey.currentState?.loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un valor por defecto seguro si las localizaciones aún no cargaron (raro, pero posible en init)
    final l10n = AppLocalizations.of(context);
    final title = l10n?.appTitle ?? 'Split With Me';
    final tFriends = l10n?.friendsTab ?? 'Friends';
    final tExpenses = l10n?.expensesTab ?? 'Expenses';
    final tSettle = l10n?.btnSettle ?? 'Settle';
    final tRefresh = l10n?.btnRefresh ?? 'Refresh';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: TabBar(
            tabs: [
              Tab(text: tFriends),
              Tab(text: tExpenses),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FriendsView(key: friendsKey),
            ExpensesView(key: expensesKey),
          ],
        ),
        persistentFooterButtons: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showSettleDebtDialog(context),
                child: Text(tSettle),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  friendsKey.currentState?.loadFriends();
                  expensesKey.currentState?.loadExpenses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshing...')),
                  );
                },
                child: Text(tRefresh),
              ),
            ],
          ),
        ],
      ),
    );
  }
}