import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'models.dart';
import 'repositories.dart';
import 'friend_details_view.dart';
import 'friend_form_dialog.dart';
import 'main.dart';
import 'l10n/app_localizations.dart';

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
    
    try {
      final repo = Provider.of<FriendRepository>(context, listen: false);
      _friendsList = await repo.getAllFriends();

      if (_friendsList.isEmpty) {
        // Lógica opcional de datos de ejemplo
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo recuperar la lista de amigos')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    try {
      final repo = Provider.of<FriendRepository>(context, listen: false);
      await repo.deleteFriend(friendId);

      setState(() {
        _friendsList.removeWhere((f) => f.isarId == friendId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.friendDeleted)), 
        ).closed.then((_) {
           loadFriends();
           MainTabView.expensesKey.currentState?.loadExpenses();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar amigo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
      // CAMBIO AQUÍ: Se cambió de 'endTop' a 'endFloat' para bajar el botón a la esquina inferior derecha
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _friendsList.isEmpty
          ? Center(child: Text(l10n.noFriends))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: _friendsList.length,
              itemBuilder: (context, index) {
                final friend = _friendsList[index];
                final netBalance = friend.netBalance;

                return Dismissible(
                  key: Key(friend.isarId.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteFriend(friend.isarId);
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
                            '${friend.name} - ${netBalance.toStringAsFixed(2)}${l10n.currencySymbol}',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: netBalance < 0 ? Colors.red : (netBalance > 0 ? Colors.green : Colors.black),
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendDetailsView(friend: friend),
                              ),
                            ).then((_) => loadFriends());
                          },
                          child: Text(l10n.showAll),
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