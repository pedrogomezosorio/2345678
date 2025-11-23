// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SPLIT WITH ME';

  @override
  String get friendsTab => 'AMIGOS';

  @override
  String get expensesTab => 'GASTOS';

  @override
  String get btnSettle => 'LIQUIDAR DEUDA';

  @override
  String get btnRefresh => 'ACTUALIZAR';

  @override
  String get showAll => 'VER DETALLES';

  @override
  String get noFriends => 'No hay amigos aún';

  @override
  String get friendDeleted => 'Amigo eliminado';

  @override
  String get currencySymbol => '€';

  @override
  String get noExpenses => 'No hay gastos (A1: Sin datos)';

  @override
  String get expenseDeleted => 'Gasto eliminado (UC-04)';
}
