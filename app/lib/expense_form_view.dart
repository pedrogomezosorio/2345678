// lib/expense_form_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';

class ExpenseFormView extends StatefulWidget {
  final bool isEditing;
  final Expense? expense; 

  const ExpenseFormView({super.key, required this.isEditing, this.expense});

  @override
  State<ExpenseFormView> createState() => _ExpenseFormViewState();
}

class _ExpenseFormViewState extends State<ExpenseFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Friend> _availableFriends = [];
  final List<Friend> _participants = []; 
  bool _isLoadingFriends = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableFriends();
    
    if (widget.isEditing && widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
      // Cargar participantes existentes (asumiendo que los links están cargados)
      _participants.addAll(widget.expense!.participants.toList());
    }
  }

  Future<void> _loadAvailableFriends() async {
    final repo = Provider.of<FriendRepository>(context, listen: false);
    _availableFriends = await repo.getAllFriends();
    setState(() => _isLoadingFriends = false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final repo = Provider.of<ExpenseRepository>(context, listen: false);
      
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      
      final newExpense = widget.expense ?? Expense(
        description: _descriptionController.text,
        date: _selectedDate,
        amount: amount,
        numFriends: _participants.length,
        totalCreditBalance: amount, // Asume que el usuario que lo crea lo pagó
      );

      newExpense.participants.clear();
      newExpense.participants.addAll(_participants);
      
      await repo.saveExpense(newExpense);

      final action = widget.isEditing ? 'Modificado' : 'Creado';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gasto $action (UC-02/03) exitosamente')),
      );
      Navigator.pop(context, true); // Retorna 'true' para indicar éxito
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isEditing ? 'MODIFICAR GASTO' : 'CREAR GASTO';
    
    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- Description ---
              Text('Description', style: Theme.of(context).textTheme.titleMedium),
              TextFormField(
                controller: _descriptionController,
                validator: (value) => value!.isEmpty ? 'La descripción no puede estar vacía' : null,
                onSaved: (value) => _descriptionController.text = value!,
              ),
              const SizedBox(height: 20),

              // --- Fecha ---
              Text('Fecha', style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_selectedDate.year} / ${_selectedDate.month.toString().padLeft(2, '0')} / ${_selectedDate.day.toString().padLeft(2, '0')}', 
                      style: const TextStyle(fontSize: 16.0)
                    )
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.grey),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Monto ---
              Text('Monto', style: Theme.of(context).textTheme.titleMedium),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) return 'Ingrese un monto válido (> 0)';
                  return null;
                },
                decoration: const InputDecoration(suffixText: '\$'),
              ),
              const SizedBox(height: 20),

              // --- Participantes ---
              Text('Participantes:', style: Theme.of(context).textTheme.titleMedium),
              if (_isLoadingFriends)
                const Center(child: CircularProgressIndicator())
              else
                ..._availableFriends.map((friend) {
                  return CheckboxListTile(
                    title: Text(friend.name),
                    value: _participants.any((p) => p.isarId == friend.isarId),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          _participants.add(friend);
                        } else {
                          _participants.removeWhere((p) => p.isarId == friend.isarId);
                        }
                      });
                    },
                    dense: true,
                  );
                }).toList(),
              const SizedBox(height: 40),

              // --- Botón CONFIRMAR ---
              Center(
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text('CONFIRMAR', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
