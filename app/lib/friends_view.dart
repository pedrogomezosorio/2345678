import 'package:flutter/material.dart';
import 'package:splitwithfriends/utils/command.dart';
import 'friends_viewmodel.dart';
import 'models.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({
    super.key,
    required this.title,
    required this.viewModel,
  });

  final String title;
  final FriendViewModel viewModel;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          widget.viewModel,
          widget.viewModel.load,
          widget.viewModel.addFriend,
          widget.viewModel.removeFriend,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              if (widget.viewModel.load.running ||
                  widget.viewModel.addFriend.running ||
                  widget.viewModel.removeFriend.running)
                Center(child: CircularProgressIndicator()),

              widget.viewModel.friends.isEmpty
                  ? Center(child: Text("No friends"))
                  : CustomScrollView(
                      slivers: [
                        if (widget.viewModel.load.error ||
                            widget.viewModel.addFriend.error ||
                            widget.viewModel.removeFriend.error)
                          SliverToBoxAdapter(
                            child: InfoBar(
                              message: widget.viewModel.errorMessage!,
                              onPressed: widget.viewModel.load.error
                                  ? widget.viewModel.load.clearResult
                                  : widget.viewModel.addFriend.error
                                  ? widget.viewModel.addFriend.clearResult
                                  : widget.viewModel.removeFriend.clearResult,
                              isError: true,
                            ),
                          ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return FriendRow(
                              friend: widget.viewModel.friends[index],
                              onRemove: widget.viewModel.removeFriend,
                            );
                          }, childCount: widget.viewModel.friends.length),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 200)),
                      ],
                    ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => FriendDialog(viewModel: widget.viewModel),
        ),
        tooltip: 'Add friend',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class FriendRow extends StatelessWidget {
  const FriendRow({super.key, required this.friend, required this.onRemove});

  final Friend friend;
  final Command1 onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        key: ValueKey("friend-${friend.id}"),
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(child: Text(friend.name.substring(0, 1))),
          ),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendDetailsScreen(friend: friend),
                ),
              ),
              child: Text(friend.name),
            ),
          ),
          IconButton(
            onPressed: () => onRemove.execute(friend.id),
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoBar extends StatelessWidget {
  const InfoBar({
    super.key,
    required this.message,
    required this.onPressed,
    this.isError = false,
  });

  final String message;
  final Function onPressed;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isError
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isError
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            ElevatedButton(
              onPressed: () => onPressed(),
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  isError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: Text("Dismiss"),
            ),
          ],
        ),
      ),
    );
  }
}

class FriendDialog extends StatefulWidget {
  const FriendDialog({super.key, required this.viewModel});

  final FriendViewModel viewModel;

  @override
  State<StatefulWidget> createState() => _FriendDialogState();
}

class _FriendDialogState extends State<FriendDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add new friend"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            labelText: "Name",
          ),
          controller: nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a name";
            }
            return null;
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
              widget.viewModel.addFriend.execute(nameController.text);
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}

class FriendDetailsScreen extends StatelessWidget {
  const FriendDetailsScreen({super.key, required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend details"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 10,
          color: Theme.of(context).colorScheme.onPrimary,
          shadowColor: Colors.black,

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(leading: Icon(Icons.person), title: Text(friend.name)),
                ListTile(
                  leading: Icon(Icons.credit_score, color: Colors.green),
                  title: Text(friend.creditBalance!.toStringAsFixed(2)),
                ),
                ListTile(
                  leading: Icon(Icons.credit_card, color: Colors.red),
                  title: Text(friend.debitBalance!.toStringAsFixed(2)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Action 1"),
                      onPressed: () => (),
                    ),
                    TextButton(
                      child: const Text("Action 2"),
                      onPressed: () => (),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
