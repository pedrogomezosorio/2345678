import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories.dart';
import 'models.dart';
import 'l10n/app_localizations.dart';

class FriendFormDialog extends StatefulWidget {
  const FriendFormDialog({super.key});
  @override
  State<FriendFormDialog> createState() => _FriendFormDialogState();
}

class _FriendFormDialogState extends State<FriendFormDialog> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  Future<void> _save() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final repo = Provider.of<FriendRepository>(context, listen: false);
      // AWAIT es crucial aquí para que el try-catch capture el error
      await repo.saveFriend(Friend(name: _controller.text));
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        // Mostramos el SnackBar que el test espera encontrar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo añadir al amigo ${_controller.text}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.dialogAddFriendTitle),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: l10n.hintFriendName),
        enabled: !_isSaving,
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(l10n.btnCancel),
        ),
        TextButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
            : Text(l10n.btnAdd),
        ),
      ],
    );
  }
}