// lib/friends_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart'; // Importar el tipo Id
import 'models.dart';
import 'repositories.dart';
import 'friend_details_view.dart'; 
import 'friend_form_dialog.dart'; 
import 'main.dart'; 

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => FriendsViewState();
}

class FriendsViewState extends State<FriendsView> {
  List<Friend> _friendsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFriends(); 
  }

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

  void _showAddFriendDialog() async {
    final bool? didAddFriend = await showDialog(
      context: context,
      builder: (context) => const FriendFormDialog(),
    );
    
    if (didAddFriend == true) {
      loadFriends();
      MainTabView.expensesKey.currentState?.loadExpenses();
    }
  }

  Future<void> _deleteFriend(Id friendId) async {
    if (!mounted) return;
    final repo = Provider.of<FriendRepository>(context, listen: false);
    
    await repo.deleteFriend(friendId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Amigo eliminado')),
    );
    
    MainTabView.expensesKey.currentState?.loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); 
    }
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog, 
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add), 
      ),
      // ¡LÍNEA ELIMINADA! Ya no está 'floatingActionButtonLocation: FloatingActionButtonLocation.endTop'
      
      body: _friendsList.isEmpty
          ? const Center(child: Text('No hay amigos (A1: Sin datos)'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: _friendsList.length,
              itemBuilder: (context, index) {
                final friend = _friendsList[index];
                final netBalance = friend.totalCreditBalance - friend.totalDebitBalance;
                
                return Dismissible(
                  key: Key(friend.isarId.toString()), 
                  direction: DismissDirection.endToStart, 
                  
                  onDismissed: (direction) {
                    _deleteFriend(friend.isarId); // Llama al borrado
                    
                    setState(() {
                      _friendsList.removeAt(index);
                    });
                  },

                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${friend.name} - \$${netBalance.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 25.0),
                          ),
                        ),
                        
                        OutlinedButton(
                          onPressed: () {
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
                  ),
                );
              },
            ),
    );
  }
}