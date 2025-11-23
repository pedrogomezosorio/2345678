import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'models.dart';
import 'repositories.dart';
import 'l10n/app_localizations.dart';

class ExpenseFormView extends StatefulWidget {
  final bool isEditing;
  final Expense? expense;

  const ExpenseFormView({
    super.key, 
    required this.isEditing, 
    this.expense
  });

  @override
  State<ExpenseFormView> createState() => _ExpenseFormViewState();
}

class _ExpenseFormViewState extends State<ExpenseFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  Friend? _selectedPayer;
  final List<Friend> _selectedParticipants = [];
  
  List<Friend> _availableFriends = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final repo = Provider.of<FriendRepository>(context, listen: false);
    final friends = await repo.getAllFriends();

    if (!mounted) return;

    setState(() {
      _availableFriends = friends;
      
      if (widget.isEditing && widget.expense != null) {
        _descriptionController.text = widget.expense!.description;
        _amountController.text = widget.expense!.amount.toString();
        _selectedDate = widget.expense!.date;
        _selectedPayer = widget.expense!.payer.value;
        _selectedParticipants.addAll(widget.expense!.participants);
      } else {
        // Por defecto, si hay amigos, selecciona el primero como pagador
        if (friends.isNotEmpty) {
          _selectedPayer = friends.first;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar quién pagó')),
      );
      return;
    }
    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar al menos un participante')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final double amount = double.parse(_amountController.text);
      final repo = Provider.of<ExpenseRepository>(context, listen: false);

      final newExpense = Expense(
        description: _descriptionController.text,
        amount: amount,
        date: _selectedDate,
      );

      if (widget.isEditing && widget.expense != null) {
        newExpense.isarId = widget.expense!.isarId;
      }

      newExpense.payer.value = _selectedPayer;
      newExpense.participants.addAll(_selectedParticipants);

      await repo.saveExpense(newExpense);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el gasto')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Fallback manual si l10n es null (por seguridad) o usa cadenas hardcodeadas temporales
    final title = widget.isEditing ? 'Editar Gasto' : 'Nuevo Gasto';

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_availableFriends.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text(l10n?.noFriends ?? 'No hay amigos registrados. Añade amigos primero.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white))
              : const Icon(Icons.check),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            
            // Cantidad
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Monto', 
                border: const OutlineInputBorder(),
                suffixText: l10n?.currencySymbol ?? '€',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requerido';
                if (double.tryParse(value) == null) return 'Número inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fecha
            ListTile(
              title: Text('Fecha: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),

            // Pagado por
            DropdownButtonFormField<Friend>(
              value: _selectedPayer,
              decoration: const InputDecoration(labelText: 'Pagado por', border: OutlineInputBorder()),
              items: _availableFriends.map((f) {
                return DropdownMenuItem(value: f, child: Text(f.name));
              }).toList(),
              onChanged: (val) => setState(() => _selectedPayer = val),
            ),
            const SizedBox(height: 24),

            // Participantes
            const Text('Participantes (quienes dividen el gasto):', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._availableFriends.map((friend) {
              final isSelected = _selectedParticipants.any((p) => p.isarId == friend.isarId);
              return CheckboxListTile(
                title: Text(friend.name),
                value: isSelected,
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedParticipants.add(friend);
                    } else {
                      _selectedParticipants.removeWhere((p) => p.isarId == friend.isarId);
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}