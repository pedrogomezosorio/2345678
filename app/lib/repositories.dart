import 'services.dart';
import 'models.dart';
import 'utils/result.dart';

class FriendRepository {
  FriendRepository({required SplitWithMeService service}) : _service = service;
  late final SplitWithMeService _service;


  Future<Result<List<Friend>>> fetchFriends() async {
    try {
      final friends = await _service.fetchFriends();
      return Result.ok(friends);
    } on Exception catch (e){
      return Result.error(e);
    }
  }
  Future<Result<Friend>> addFriend(Friend friend) async {
    
    try {
     final newFriend = await _service.addFriend(friend);
     return Result.ok(newFriend);
    } on Exception catch (e){
      return Result.error(e);
    }
  }
  Future<Result<void>> removeFriend(int id) async {
     try {
      await _service.removeFriend(id);
      return Result.ok(null);
    } on Exception catch (e){
      return Result.error(e);
    }
  }


}
