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

  @override
  String get dialogSettleTitle => 'Liquidar Deuda';

  @override
  String get labelPayer => 'Quién paga';

  @override
  String get labelReceiver => 'Quién recibe';

  @override
  String get labelAmount => 'Monto';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnAdd => 'Añadir';

  @override
  String get btnLiquidar => 'Liquidar';

  @override
  String get dialogAddFriendTitle => 'Añadir Amigo';

  @override
  String get hintFriendName => 'Nombre del amigo';

  @override
  String get titleCreateExpense => 'CREAR GASTO';

  @override
  String get titleEditExpense => 'MODIFICAR GASTO';

  @override
  String get labelDescription => 'Descripción';

  @override
  String get labelDate => 'Fecha';

  @override
  String get labelPaidBy => 'Pagado por';

  @override
  String get labelParticipants => 'Participantes';

  @override
  String get btnConfirm => 'CONFIRMAR';

  @override
  String get msgSelectPayer => 'Seleccionar pagador';

  @override
  String headerBalance(Object name) {
    return 'Balance General de $name';
  }

  @override
  String get labelNetBalance => 'Balance Neto';

  @override
  String get labelCredit => 'Total que le deben (Crédito)';

  @override
  String get labelDebit => 'Total que debe (Débito)';

  @override
  String get headerExpensesList => 'Gastos en los que participa';

  @override
  String get msgNoExpensesFriend => 'Este amigo no participa en ningún gasto.';

  @override
  String get msgDebtSettled => 'Deuda liquidada';
}
