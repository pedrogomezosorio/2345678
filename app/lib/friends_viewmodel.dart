import 'package:flutter/material.dart';
import 'package:splitwithfriends/models.dart';

import 'repositories.dart';
import 'utils/result.dart';
import 'utils/command.dart';

class FriendViewModel extends ChangeNotifier {
  FriendViewModel({required FriendRepository friendRepository})
    : _friendRepository = friendRepository {
    load = Command0(_load);
    addFriend = Command1(_addFriend);
    removeFriend = Command1(_removeFriend);
    if (friends.isEmpty) {
      load.execute();
    }
  }

  final FriendRepository _friendRepository;
  late final Command0 load;
  late final Command1<void, String> addFriend;
  late final Command1<void, int> removeFriend;

  List<Friend> friends = [];
  String? errorMessage;

  Future<Result<void>> _load() async {
    final result = await _friendRepository.fetchFriends();
    switch (result) {
      case Ok<List<Friend>>():
        friends = result.value;
        notifyListeners();
        return Result.ok(null);
      case Error<List<Friend>>():
        errorMessage = "Cannot retrieve the list of friends";
        notifyListeners();
        return Result.error(result.error);
    }
  }

  Future<Result<void>> _addFriend(String name) async {
    final result = await _friendRepository.addFriend(Friend(name: name));

    switch (result) {
      case Ok<Friend>():
        friends.add(result.value);
      case Error<Friend>():
        errorMessage = "Cannot add friend $name";
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _removeFriend(int id) async {
    final result = await _friendRepository.removeFriend(id);

    switch (result) {
      case Ok<void>():
        friends.removeWhere((friend) => friend.id == id);
      case Error<void>():
        errorMessage = "Cannot remove friend";
    }
    notifyListeners();
    return result;
  }
}
