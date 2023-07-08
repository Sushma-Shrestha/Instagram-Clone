import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/profile_message_screen.dart';
import 'package:instagram_clone/screens/screens.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart' as users;
import '../providers/user_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _index = -1;
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final users.User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: width > webScreenSize
          ? null
          : AppBar(
              title: const Text('Messages'),
              backgroundColor: mobileBackgroundColor,
              actions: [
                IconButton(
                    padding: const EdgeInsets.only(right: 25),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SearchScreen(
                                    isMessage: true,
                                  )));
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 30,
                    ))
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('messages')
            .orderBy('lastMessagedTime', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Container(
            padding: width > webScreenSize
                ? EdgeInsets.fromLTRB(
                    width * 0.1,
                    MediaQuery.of(context).size.height * 0.05,
                    width * 0.1,
                    MediaQuery.of(context).size.height * 0.05)
                : null,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: width > webScreenSize
                          ? messageBorder
                          : mobileBackgroundColor)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        width > webScreenSize
                            ? Container(
                                decoration: const BoxDecoration(
                                  border: Border.symmetric(
                                    horizontal:
                                        BorderSide(color: messageBorder),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      user.username,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.add_comment))
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                        Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: ((context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    FirestoreMethods().removeMessageCount(
                                        user.uid,
                                        snapshot.data!.docs[index]['friendId']);

                                    setState(() {
                                      UserProvider().refreshUser();
                                    });
                                    width < webScreenSize
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ProfileMessage(
                                                    friendId: snapshot
                                                            .data!.docs[index]
                                                        ['friendId'],
                                                    friendPhoto: snapshot
                                                            .data!.docs[index]
                                                        ['friendUrl'],
                                                    userId: snapshot.data!
                                                        .docs[index]['userId'],
                                                    userPhoto: user.photoUrl,
                                                    friendName: snapshot
                                                            .data!.docs[index]
                                                        ['friendName'],
                                                    username: user.username)))
                                        : _index = index;
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: mobileBackgroundColor,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7.5),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    height: 65,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  snapshot.data!.docs[index]
                                                      ['friendUrl']),
                                        ),
                                        const SizedBox(
                                          width: 25,
                                        ),
                                        Expanded(
                                            child: Text(
                                          snapshot.data!.docs[index]
                                              ['friendName'],
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ))
                                      ],
                                    ),
                                  ),
                                );
                              })),
                        ),
                      ],
                    ),
                  ),
                  width > webScreenSize
                      ? Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: messageBorder)),
                          width: width * 0.55,
                          child: _index != -1
                              ? ProfileMessage(
                                  friendId: snapshot.data!.docs[_index]
                                      ['friendId'],
                                  friendPhoto: snapshot.data!.docs[_index]
                                      ['friendUrl'],
                                  userId: snapshot.data!.docs[_index]['userId'],
                                  userPhoto: user.photoUrl,
                                  friendName: snapshot.data!.docs[_index]
                                      ['friendName'],
                                  username: user.username)
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Your Messages',
                                          style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w400)),
                                      const Text(
                                        'Send private messages to your friends and followers',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w200,
                                            color: Colors.grey),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      TextButton(
                                          onPressed: () {},
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.blue[800],
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            width: 120,
                                            height: 30,
                                            child: const Center(
                                              child: Text(
                                                'Send Message',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                        )
                      : const SizedBox.shrink()
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
