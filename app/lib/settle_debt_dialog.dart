// lib/settle_debt_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';

class SettleDebtDialog extends StatefulWidget {
  const SettleDebtDialog({super.key});

  @override
  State<SettleDebtDialog> createState() => _SettleDebtDialogState();
}

class _SettleDebtDialogState extends State<SettleDebtDialog> {
  final _formKey = GlobalKey<FormState>();
  Friend? _payer;
  Friend? _receiver;
  final _amountController = TextEditingController();

  List<Friend> _allFriends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final repo = Provider.of<FriendRepository>(context, listen: false);
    _allFriends = await repo.getAllFriends();
    setState(() => _isLoading = false);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_payer == null || _receiver == null) return;

      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final repo = Provider.of<FriendRepository>(context, listen: false);

      // Llamamos a la nueva lógica del repositorio
      await repo.settleDebt(_payer!, _receiver!, amount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deuda de \$${amount.toStringAsFixed(2)} liquidada')),
        );
        Navigator.pop(context, true); // Devolvemos 'true' para refrescar
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Liquidar Deuda'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Quién PAGA ---
                  DropdownButtonFormField<Friend>(
                    value: _payer,
                    hint: const Text('Quién paga...'),
                    items: _allFriends.map((friend) {
                      return DropdownMenuItem(
                        value: friend,
                        child: Text(friend.name),
                      );
                    }).toList(),
                    onChanged: (Friend? newValue) {
                      setState(() => _payer = newValue);
                    },
                    validator: (value) {
                      if (value == null) return 'Selecciona un pagador';
                      if (value == _receiver) return 'No puede ser la misma persona';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // --- Quién RECIBE ---
                  DropdownButtonFormField<Friend>(
                    value: _receiver,
                    hint: const Text('Quién recibe...'),
                    items: _allFriends.map((friend) {
                      return DropdownMenuItem(
                        value: friend,
                        child: Text(friend.name),
                      );
                    }).toList(),
                    onChanged: (Friend? newValue) {
                      setState(() => _receiver = newValue);
                    },
                    validator: (value) {
                      if (value == null) return 'Selecciona un receptor';
                      if (value == _payer) return 'No puede ser la misma persona';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // --- Monto ---
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      suffixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      final amount = double.tryParse(value ?? '');
                      if (amount == null || amount <= 0) {
                        return 'Ingrese un monto válido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('LIQUIDAR'),
        ),
      ],
    );
  }
}