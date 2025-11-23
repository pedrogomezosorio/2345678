import 'package:isar/isar.dart';

part 'models.g.dart';

@collection
class Friend {
  Id isarId = Isar.autoIncrement;

  final String name;
  
  double totalCreditBalance; 
  double totalDebitBalance;  

  Friend({
    required this.name, 
    this.totalCreditBalance = 0.0, 
    this.totalDebitBalance = 0.0,
  });

  double get netBalance => totalCreditBalance - totalDebitBalance;
}

@collection
class Expense {
  Id isarId = Isar.autoIncrement;

  String description; 
  DateTime date;      
  double amount;      
  
  final payer = IsarLink<Friend>();
  final participants = IsarLinks<Friend>(); 

  Expense({
    required this.description,
    required this.date,
    required this.amount,
  });
}