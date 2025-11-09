import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitwithfriends/services.dart';

import 'friends_view.dart';
import 'friends_viewmodel.dart';
import 'repositories.dart';

void main() {
  var providers = [
    Provider(
      create: (context) => FriendRepository(service: SplitWithMeAPIService()),
    ),
  ];

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitWithFriends',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: FriendsScreen(
        title: 'Friend list',
        viewModel: FriendViewModel(friendRepository: context.read()),
      ),
    );
  }
}
