import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';
import 'l10n/app_localizations.dart';

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    if (!mounted) return;
    try {
      final repo = Provider.of<FriendRepository>(context, listen: false);
      _allFriends = await repo.getAllFriends();
    } catch (e) {
      // Manejo silencioso
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_payer == null || _receiver == null) return;
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      
      setState(() => _isSaving = true);
      try {
        final repo = Provider.of<FriendRepository>(context, listen: false);
        await repo.settleDebt(_payer!, _receiver!, amount);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.msgDebtSettled}: ${amount.toStringAsFixed(2)}')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al liquidar deuda')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      scrollable: true, // CORREGIDO: Crucial para tests en pantallas pequeñas
      title: Text(l10n.dialogSettleTitle),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Friend>(
                    value: _payer,
                    hint: Text('${l10n.labelPayer}...'),
                    items: _allFriends.map((friend) {
                      return DropdownMenuItem(value: friend, child: Text(friend.name));
                    }).toList(),
                    onChanged: (val) => setState(() => _payer = val),
                    validator: (val) => val == null ? l10n.msgSelectPayer : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Friend>(
                    value: _receiver,
                    hint: Text('${l10n.labelReceiver}...'),
                    items: _allFriends.map((friend) {
                      return DropdownMenuItem(value: friend, child: Text(friend.name));
                    }).toList(),
                    onChanged: (val) => setState(() => _receiver = val),
                    validator: (val) => val == null ? l10n.msgSelectPayer : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: l10n.labelAmount,
                      suffixText: l10n.currencySymbol,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) return 'Error';
                      return null;
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.btnCancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(l10n.btnLiquidar),
        ),
      ],
    );
  }
}