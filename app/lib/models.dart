// lib/models.dart

import 'package:isar/isar.dart';

// El archivo que será generado automáticamente.
part 'models.g.dart'; 

// --- 1. COLECCIÓN DE AMIGOS (FRIEND) ---
@collection
class Friend {
  // Isar ID (Primary Key)
  Id isarId = Isar.autoIncrement;

  // Campos de Friend
  final String name; 
  final double totalCreditBalance; 
  final double totalDebitBalance;  

  // Constructor
  Friend({
    required this.name, 
    this.totalCreditBalance = 0.0, 
    this.totalDebitBalance = 0.0,
  });
}

// --- 2. COLECCIÓN DE GASTOS (EXPENSE) ---
@collection
class Expense {
  // Isar ID (Primary Key)
  Id isarId = Isar.autoIncrement;

  // Campos de Expense (UC-01)
  final String description; 
  final DateTime date;      
  final double amount;      
  final int numFriends;     
  final double totalCreditBalance; 
  
  // RELACIÓN: Amigos que participan en este gasto
  final participants = IsarLinks<Friend>(); 

  // Constructor
  Expense({
    required this.description,
    required this.date,
    required this.amount,
    this.numFriends = 0,
    this.totalCreditBalance = 0.0,
  });
}
