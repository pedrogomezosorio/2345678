// lib/friend_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';

class FriendFormDialog extends StatefulWidget {
  const FriendFormDialog({super.key});

  @override
  State<FriendFormDialog> createState() => _FriendFormDialogState();
}

class _FriendFormDialogState extends State<FriendFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final repo = Provider.of<FriendRepository>(context, listen: false);
      final newFriend = Friend(name: _nameController.text);
      await repo.saveFriend(newFriend);
      
      // Cerramos el diálogo y devolvemos 'true' para indicar éxito
      if (mounted) {
        Navigator.pop(context, true); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir Amigo'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nombre del amigo'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El nombre no puede estar vacío';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // Devuelve 'false'
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('AÑADIR'),
        ),
      ],
    );
  }
}