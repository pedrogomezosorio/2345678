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
  double totalCreditBalance; // CAMBIADO: De 'final' a 'mutable' para poder actualizarlo
  double totalDebitBalance;  // CAMBIADO: De 'final' a 'mutable' para poder actualizarlo

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
  
  // RELACIÓN: Quién pagó este gasto
  final payer = IsarLink<Friend>(); // ¡NUEVO!

  // RELACIÓN: Amigos que participan en este gasto
  final participants = IsarLinks<Friend>(); 

  // Constructor
  Expense({
    required this.description,
    required this.date,
    required this.amount,
  });

  // --- CAMPOS OBSOLETOS ---
  // Estos campos estaban en tu modelo original, pero son redundantes o
  // deberían estar en el 'Friend' (como el balance). Los mantenemos
  // comentados por si los usas en otro sitio, pero la nueva lógica no los usa.
  
  // final int numFriends;     
  // final double totalCreditBalance; 
}