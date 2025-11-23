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

  @override
  String get dialogSettleTitle => 'Settle Debt';

  @override
  String get labelPayer => 'Who pays';

  @override
  String get labelReceiver => 'Who receives';

  @override
  String get labelAmount => 'Amount';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnAdd => 'Add';

  @override
  String get btnLiquidar => 'Settle';

  @override
  String get dialogAddFriendTitle => 'Add Friend';

  @override
  String get hintFriendName => 'Friend\'s name';

  @override
  String get titleCreateExpense => 'CREATE EXPENSE';

  @override
  String get titleEditExpense => 'EDIT EXPENSE';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelDate => 'Date';

  @override
  String get labelPaidBy => 'Paid by';

  @override
  String get labelParticipants => 'Participants';

  @override
  String get btnConfirm => 'CONFIRM';

  @override
  String get msgSelectPayer => 'Select payer';

  @override
  String headerBalance(Object name) {
    return '$name\'s General Balance';
  }

  @override
  String get labelNetBalance => 'Net Balance';

  @override
  String get labelCredit => 'Total Credit';

  @override
  String get labelDebit => 'Total Debit';

  @override
  String get headerExpensesList => 'Expenses participated in';

  @override
  String get msgNoExpensesFriend => 'This friend has no expenses.';

  @override
  String get msgDebtSettled => 'Debt settled';
}
