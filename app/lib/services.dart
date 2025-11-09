import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

abstract class SplitWithMeService {
  Future<List<Friend>> fetchFriends();
  Future<Friend> addFriend(Friend friend);
  Future<void> removeFriend(int id);
}

class SplitWithMeAPIService implements SplitWithMeService {
  final serverURL = Platform.isAndroid ? "10.0.2.2" : "127.0.0.1";
  final serverPort = "8000";

  @override
  Future<List<Friend>> fetchFriends() async {
    var uri = Uri.http("$serverURL:$serverPort", "friends");
    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return List<Friend>.from(data.map((item) => Friend.fromJson(item)));
      } else {
        throw ServerException("Invalid data");
      }
    } on http.ClientException {
      throw ServerException("Service is not available. Try again later.");
    }
  }

  @override
  Future<Friend> addFriend(Friend friend) async {
    var uri = Uri.http("$serverURL:$serverPort", "friends/");
    try {
      var response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
        body: json.encode({'name': friend.name}),
      );
      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        return Friend.fromJson(data);
      } else {
        throw ServerException("Invalid data");
      }
    } on http.ClientException {
      throw ServerException("Service is not available. Try again later.");
    }
  }

  @override
  Future<void> removeFriend(int id) async {
    var uri = Uri.http("$serverURL:$serverPort", "friends/$id");
    try {
      var response = await http.delete(uri);
      if (response.statusCode == 204) {
        return;
      } else {
        throw ServerException("Invalid data");
      }
    } on http.ClientException {
      throw ServerException("Service is not available. Try again later.");
    }
  }
}
