import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';

class ProfileMessage extends StatefulWidget {
  final String username;
  final String friendId;
  final String friendPhoto;
  final String userId;
  final String friendName;
  final String userPhoto;
  const ProfileMessage(
      {Key? key,
      required this.friendId,
      required this.friendPhoto,
      required this.userId,
      required this.userPhoto,
      required this.friendName,
      required this.username})
      : super(key: key);

  @override
  _ProfileMessageState createState() => _ProfileMessageState();
}

class _ProfileMessageState extends State<ProfileMessage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: width > webScreenSize
            ? null
            : AppBar(
                backgroundColor: mobileBackgroundColor,
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(uid: widget.friendId)));
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.blue,
                        backgroundImage:
                            CachedNetworkImageProvider(widget.friendPhoto),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(widget.friendName)
                    ],
                  ),
                ),
              ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('messages')
              .doc(widget.friendId)
              .collection('messageList')
              .orderBy('messagedTime', descending: true)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData) {
              return Column(
                children: [
                  width > webScreenSize
                      ? Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: messageBorder)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          width: double.infinity,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 17,
                                backgroundColor: Colors.blue,
                                backgroundImage: CachedNetworkImageProvider(
                                    widget.friendPhoto),
                              ),
                              SizedBox(
                                width: width > webScreenSize ? 25 : 15,
                              ),
                              Text(
                                widget.friendName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 18),
                              )
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                  Flexible(
                    child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.only(bottom: 15),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) => snapshot
                                    .data!.docs[index]['type'] ==
                                'S'
                            ? Container(
                                padding: const EdgeInsets.only(
                                    left: 15, top: 15, right: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: width > webScreenSize
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.82),
                                      child: GestureDetector(
                                        onLongPress: () {
                                          showDialog(
                                              context: (context),
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        onTap: () {
                                                          FirestoreMethods()
                                                              .unsendMessage(
                                                                  widget.userId,
                                                                  widget
                                                                      .friendId,
                                                                  snapshot.data!
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'messageId']);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        title: const Text(
                                                          'Unsend',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        title: const Text(
                                                            'Cancel'),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              });
                                        },
                                        child: GestureDetector(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.blue[700],
                                            ),
                                            margin: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                right: 15),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Text(
                                                snapshot.data!.docs[index]
                                                    ['message'],
                                                style: const TextStyle(
                                                    fontSize: 16)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              widget.userPhoto),
                                      radius: 17,
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              widget.friendPhoto),
                                      radius: 17,
                                    ),
                                    Container(
                                      constraints: width > webScreenSize
                                          ? BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5)
                                          : BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.grey[700],
                                          ),
                                          margin: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              left: 15),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Text(
                                            snapshot.data!.docs[index]
                                                ['message'],
                                            style:
                                                const TextStyle(fontSize: 16),
                                          )),
                                    ),
                                  ],
                                ),
                              )),
                  ),
                ],
              );
            } else {
              return const Text('No Messages');
            }
          },
        ),
        bottomNavigationBar: MessageBox(
          friendName: widget.friendName,
          friendPhoto: widget.friendPhoto,
          userId: widget.userId,
          friendid: widget.friendId,
          userUrl: widget.userPhoto,
          username: widget.username,
        ));
  }
}

class MessageBox extends StatefulWidget {
  final String userId;
  final String friendid;
  final String friendPhoto;
  final String userUrl;
  final String friendName;
  final String username;
  const MessageBox({
    Key? key,
    required this.userId,
    required this.friendid,
    required this.friendPhoto,
    required this.userUrl,
    required this.friendName,
    required this.username,
  }) : super(key: key);

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  var messageController = TextEditingController();
  final FocusNode myFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  bool startedTyping = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: kToolbarHeight,
      margin: width < webScreenSize
          ? EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 5)
          : const EdgeInsets.symmetric(horizontal: 7.5),
      decoration: BoxDecoration(
        border: Border.all(color: messageBorder),
        borderRadius: (BorderRadius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt,
                size: 25,
                color: Colors.white,
              )),
          width > webScreenSize
              ? const SizedBox(
                  width: 20,
                )
              : const SizedBox.shrink(),
          Expanded(
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.done,
              focusNode: myFocusNode,
              controller: messageController,
              onChanged: (text) {
                if (text != '') {
                  if (startedTyping == false) {
                    setState(() {
                      startedTyping = true;
                    });
                  }
                } else {
                  setState(() {
                    startedTyping = false;
                  });
                }
              },
              onSubmitted: (value) {
                if (width > webScreenSize) {
                  if (messageController.text.trim().isEmpty) {
                  } else {
                    FirestoreMethods().sendMessage(
                        widget.userId,
                        widget.friendid,
                        messageController.text,
                        widget.friendPhoto,
                        widget.userUrl,
                        widget.friendName,
                        widget.username);
                  }
                  messageController.text = '';
                }
                setState(() {
                  startedTyping = false;
                  FocusScope.of(context).unfocus();
                  FocusScope.of(context).requestFocus(myFocusNode);
                });
              },
              decoration: const InputDecoration(
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Message..'),
            ),
          ),
          startedTyping
              ? Padding(
                  padding: const EdgeInsets.only(right: 20, left: 50),
                  child: GestureDetector(
                    onTap: () {
                      if (messageController.text.trim().isEmpty) {
                      } else {
                        FirestoreMethods().sendMessage(
                            widget.userId,
                            widget.friendid,
                            messageController.text,
                            widget.friendPhoto,
                            widget.userUrl,
                            widget.friendName,
                            widget.username);
                      }

                      messageController.text = '';
                    },
                    child: const Text(
                      'Send',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.blue),
                    ),
                  ),
                )
              : Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.mic_sharp),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.photo),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.sticky_note_2),
                    ),
                  ],
                )
        ],
      ),
    );
  }
}
