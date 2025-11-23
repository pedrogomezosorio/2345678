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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.dialogAddFriendTitle), // "Añadir Amigo"
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: l10n.hintFriendName),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.btnCancel),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              final repo = Provider.of<FriendRepository>(context, listen: false);
              repo.saveFriend(Friend(name: _controller.text));
              Navigator.pop(context, true);
            }
          },
          child: Text(l10n.btnAdd),
        ),
      ],
    );
  }
}