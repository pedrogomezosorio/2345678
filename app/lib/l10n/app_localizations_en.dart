// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SPLIT WITH ME';

  @override
  String get friendsTab => 'FRIENDS';

  @override
  String get expensesTab => 'EXPENSES';

  @override
  String get btnSettle => 'SETTLE DEBT';

  @override
  String get btnRefresh => 'REFRESH';

  @override
  String get showAll => 'SHOW ALL';

  @override
  String get noFriends => 'No friends yet';

  @override
  String get friendDeleted => 'Friend deleted';

  @override
  String get currencySymbol => '\$';

  @override
  String get noExpenses => 'No expenses yet';

  @override
  String get expenseDeleted => 'Expense deleted';
}
