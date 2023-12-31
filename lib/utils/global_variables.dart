import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/screens.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Center(
    child: Text('Notification'),
  ),
  Builder(builder: (context) {
    return ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid);
  }),
];

List<Widget> webHomeScreenItems = [
  const FeedScreen(),
  const MessagesScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Center(
    child: Text('Notification'),
  ),
  Builder(builder: (context) {
    return ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid);
  }),
];
