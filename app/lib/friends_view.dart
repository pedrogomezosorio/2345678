// lib/friends_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';
import 'friend_details_view.dart'; // ¡NUEVO! Importar vista detalle
import 'friend_form_dialog.dart'; // ¡NUEVO! Importar diálogo

class FriendsView extends StatefulWidget {
  // ¡ACTUALIZADO! Se requiere una Key para el REFRESH
  const FriendsView({super.key});

  @override
  // ¡ACTUALIZADO! Nombre de la clase de estado es ahora público
  State<FriendsView> createState() => FriendsViewState();
}

// ¡ACTUALIZADO! La clase de estado ahora es pública 'FriendsViewState'
class FriendsViewState extends State<FriendsView> {
  List<Friend> _friendsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFriends(); // Renombrado de _loadFriends
  }

  // ¡ACTUALIZADO! Método ahora público para ser llamado por el REFRESH
  Future<void> loadFriends() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final repo = Provider.of<FriendRepository>(context, listen: false);
    
    _friendsList = await repo.getAllFriends();

    if (_friendsList.isEmpty) {
      final initialFriends = [
        Friend(name: 'Friend 1'),
        Friend(name: 'Friend 2'),
      ];
      for (var friend in initialFriends) {
        await repo.saveFriend(friend);
      }
      _friendsList = await repo.getAllFriends();
    }
    
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // ¡NUEVO! Método para mostrar el diálogo de añadir amigo
  void _showAddFriendDialog() async {
    // Muestra el diálogo y espera un resultado
    final bool? didAddFriend = await showDialog(
      context: context,
      builder: (context) => const FriendFormDialog(),
    );
    
    // Si el diálogo devolvió 'true', recargamos la lista
    if (didAddFriend == true) {
      loadFriends();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); 
    }
    
    return Scaffold(
      // ¡ACTUALIZADO! Botón "+" ahora llama al diálogo
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog, // Llama al nuevo método
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add), 
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      
      body: _friendsList.isEmpty
          ? const Center(child: Text('No hay amigos (A1: Sin datos)'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: _friendsList.length,
              itemBuilder: (context, index) {
                final friend = _friendsList[index];
                final netBalance = friend.totalCreditBalance - friend.totalDebitBalance;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${friend.name} - \$${netBalance.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                      
                      // ¡ACTUALIZADO! Botón "SHOW ALL" (UC-07)
                      OutlinedButton(
                        onPressed: () {
                          // ¡NUEVA LÓGICA! Navegar a la vista de detalle
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendDetailsView(friend: friend),
                            ),
                          );
                        },
                        child: const Text('SHOW ALL'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}