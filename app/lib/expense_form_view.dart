import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';
import 'package:isar/isar.dart';
import 'l10n/app_localizations.dart';

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
  Friend? _selectedPayer; 
  
  bool _isLoadingFriends = true;

  late Isar _isar;
  late FriendRepository _friendRepo;
  late ExpenseRepository _expenseRepo;

  @override
  void initState() {
    super.initState();
    _isar = Provider.of<Isar>(context, listen: false);
    _friendRepo = Provider.of<FriendRepository>(context, listen: false);
    _expenseRepo = Provider.of<ExpenseRepository>(context, listen: false);
    
    _loadAvailableFriends();
    
    if (widget.isEditing && widget.expense != null) {
      final expense = widget.expense!;
      _descriptionController.text = expense.description;
      _amountController.text = expense.amount.toString();
      _selectedDate = expense.date;
      
      expense.participants.loadSync();
      expense.payer.loadSync();
      
      _participants.addAll(expense.participants);
      _selectedPayer = expense.payer.value;
    }
  }

  Future<void> _loadAvailableFriends() async {
    _availableFriends = await _friendRepo.getAllFriends();
    if (widget.isEditing && _selectedPayer != null) {
      _selectedPayer = _availableFriends.firstWhere(
        (f) => f.isarId == _selectedPayer!.isarId,
        orElse: () => _selectedPayer!,
      );
    }
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

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (_selectedPayer == null || _participants.isEmpty) {
      return; 
    }
    
    await _isar.writeTxn(() async {
      Expense expenseToSave;
      
      if (widget.isEditing && widget.expense != null) {
        expenseToSave = widget.expense!;
        // Revertir lógica anterior (Simplificado para el ejemplo)
        await expenseToSave.payer.load();
        await expenseToSave.participants.load();
        
        final oldPayer = expenseToSave.payer.value;
        final oldParticipants = expenseToSave.participants.toList();
        final oldAmount = expenseToSave.amount;
        
        if (oldPayer != null && oldParticipants.isNotEmpty) {
          final oldAmountPerParticipant = oldAmount / oldParticipants.length;
          oldPayer.totalCreditBalance -= oldAmount;
          await _friendRepo.saveFriend(oldPayer);
          for (var p in oldParticipants) {
            p.totalDebitBalance -= oldAmountPerParticipant;
            await _friendRepo.saveFriend(p);
          }
        }
      } else {
        expenseToSave = Expense(
          description: _descriptionController.text,
          date: _selectedDate,
          amount: amount,
        );
      }

      expenseToSave.description = _descriptionController.text;
      expenseToSave.date = _selectedDate;
      expenseToSave.amount = amount;
      expenseToSave.payer.value = _selectedPayer;
      expenseToSave.participants.clear();
      expenseToSave.participants.addAll(_participants);

      final double amountPerParticipant = amount / _participants.length;

      final payer = await _friendRepo.getFriendById(_selectedPayer!.isarId);
      if (payer != null) {
        payer.totalCreditBalance += amount;
        await _friendRepo.saveFriend(payer);
      }

      for (var participant in _participants) {
        final pFriend = await _friendRepo.getFriendById(participant.isarId);
        if (pFriend != null) {
          pFriend.totalDebitBalance += amountPerParticipant;
          await _friendRepo.saveFriend(pFriend);
        }
      }
      
      await _expenseRepo.saveExpense(expenseToSave);
    });

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titleText = widget.isEditing ? l10n.titleEditExpense : l10n.titleCreateExpense;
    
    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(l10n.labelDescription, style: Theme.of(context).textTheme.titleMedium),
              TextFormField(
                controller: _descriptionController,
                validator: (value) => value!.isEmpty ? 'Error' : null,
              ),
              const SizedBox(height: 20),

              Text(l10n.labelDate, style: Theme.of(context).textTheme.titleMedium),
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

              Text(l10n.labelAmount, style: Theme.of(context).textTheme.titleMedium),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) return 'Error';
                  return null;
                },
                decoration: InputDecoration(suffixText: l10n.currencySymbol),
              ),
              const SizedBox(height: 20),

              Text('${l10n.labelPaidBy}:', style: Theme.of(context).textTheme.titleMedium),
              if (_isLoadingFriends)
                const CircularProgressIndicator()
              else
                DropdownButtonFormField<Friend>(
                  value: _selectedPayer,
                  hint: Text(l10n.msgSelectPayer),
                  validator: (value) => value == null ? 'Error' : null,
                  items: _availableFriends.map((friend) {
                    return DropdownMenuItem(value: friend, child: Text(friend.name));
                  }).toList(),
                  onChanged: (Friend? newValue) {
                    setState(() => _selectedPayer = newValue);
                  },
                ),
              const SizedBox(height: 20),

              Text('${l10n.labelParticipants}:', style: Theme.of(context).textTheme.titleMedium),
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

              Center(
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(l10n.btnConfirm, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}