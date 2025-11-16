// lib/friends_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'repositories.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  List<Friend> _friendsList = [];
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
    
    _friendsList = await repo.getAllFriends();

    // Insertar datos de ejemplo si está vacío (Page 6)
    if (_friendsList.isEmpty) {
      final initialFriends = [
        Friend(name: 'Friend 1'),
        Friend(name: 'Friend 2'),
        Friend(name: 'Friend 3'),
        Friend(name: 'Friend 4'),
        Friend(name: 'Friend 5'),
      ];
      for (var friend in initialFriends) {
        await repo.saveFriend(friend);
      }
      _friendsList = await repo.getAllFriends();
    }
    
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); 
    }
    if (_friendsList.isEmpty) {
      return const Center(child: Text('No hay amigos (A1: Sin datos)')); 
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Fuera de alcance: Añadir amigo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Añadir amigo (Fuera de alcance)')),
          );
        },
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add), 
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      
      body: ListView.builder(
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
                
                // Botón "SHOW ALL" (UC-07)
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ver detalle de ${friend.name} (UC-07)')),
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
