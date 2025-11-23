import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SPLIT WITH ME'**
  String get appTitle;

  /// No description provided for @friendsTab.
  ///
  /// In en, this message translates to:
  /// **'FRIENDS'**
  String get friendsTab;

  /// No description provided for @expensesTab.
  ///
  /// In en, this message translates to:
  /// **'EXPENSES'**
  String get expensesTab;

  /// No description provided for @btnSettle.
  ///
  /// In en, this message translates to:
  /// **'SETTLE DEBT'**
  String get btnSettle;

  /// No description provided for @btnRefresh.
  ///
  /// In en, this message translates to:
  /// **'REFRESH'**
  String get btnRefresh;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'SHOW ALL'**
  String get showAll;

  /// No description provided for @noFriends.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriends;

  /// No description provided for @friendDeleted.
  ///
  /// In en, this message translates to:
  /// **'Friend deleted'**
  String get friendDeleted;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get currencySymbol;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpenses;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @dialogSettleTitle.
  ///
  /// In en, this message translates to:
  /// **'Settle Debt'**
  String get dialogSettleTitle;

  /// No description provided for @labelPayer.
  ///
  /// In en, this message translates to:
  /// **'Who pays'**
  String get labelPayer;

  /// No description provided for @labelReceiver.
  ///
  /// In en, this message translates to:
  /// **'Who receives'**
  String get labelReceiver;

  /// No description provided for @labelAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get labelAmount;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btnAdd;

  /// No description provided for @btnLiquidar.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get btnLiquidar;

  /// No description provided for @dialogAddFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get dialogAddFriendTitle;

  /// No description provided for @hintFriendName.
  ///
  /// In en, this message translates to:
  /// **'Friend\'s name'**
  String get hintFriendName;

  /// No description provided for @titleCreateExpense.
  ///
  /// In en, this message translates to:
  /// **'CREATE EXPENSE'**
  String get titleCreateExpense;

  /// No description provided for @titleEditExpense.
  ///
  /// In en, this message translates to:
  /// **'EDIT EXPENSE'**
  String get titleEditExpense;

  /// No description provided for @labelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelDescription;

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// No description provided for @labelPaidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get labelPaidBy;

  /// No description provided for @labelParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get labelParticipants;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get btnConfirm;

  /// No description provided for @msgSelectPayer.
  ///
  /// In en, this message translates to:
  /// **'Select payer'**
  String get msgSelectPayer;

  /// No description provided for @headerBalance.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s General Balance'**
  String headerBalance(Object name);

  /// No description provided for @labelNetBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get labelNetBalance;

  /// No description provided for @labelCredit.
  ///
  /// In en, this message translates to:
  /// **'Total Credit'**
  String get labelCredit;

  /// No description provided for @labelDebit.
  ///
  /// In en, this message translates to:
  /// **'Total Debit'**
  String get labelDebit;

  /// No description provided for @headerExpensesList.
  ///
  /// In en, this message translates to:
  /// **'Expenses participated in'**
  String get headerExpensesList;

  /// No description provided for @msgNoExpensesFriend.
  ///
  /// In en, this message translates to:
  /// **'This friend has no expenses.'**
  String get msgNoExpensesFriend;

  /// No description provided for @msgDebtSettled.
  ///
  /// In en, this message translates to:
  /// **'Debt settled'**
  String get msgDebtSettled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
