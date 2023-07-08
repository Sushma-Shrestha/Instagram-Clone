import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/widgets.dart';

// ignore: must_be_immutable
class FollowerScreen extends StatefulWidget {
  final String uid;
  final String username;
  bool? isFollowing;
  FollowerScreen(
      {Key? key, required this.uid, this.isFollowing, required this.username})
      : super(key: key);

  @override
  _FollowerScreenState createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<FollowerScreen> {
  String photoUrl = '';
  late bool isOwnProfile;
  @override
  void initState() {
    super.initState();

    if (widget.uid == FirebaseAuth.instance.currentUser!.uid) {
      isOwnProfile = true;
    } else {
      isOwnProfile = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    alert({required bool isFollowing, required snap, required int index}) {
      return showDialog(
          context: (context),
          builder: (context) => Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: AlertDialog(
                  title: Column(
                    children: [
                      const Text(
                        'Are you sure?',
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        !isFollowing
                            ? 'You may have to request again to follow the user!'
                            : 'Once removed only they can follow you back!',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ListTile(
                        onTap: () {
                          isOwnProfile
                              ? !isFollowing
                                  ? FirestoreMethods().followUser(
                                      widget.uid,
                                      (snap.data as dynamic)['following']
                                          [index])
                                  : FirestoreMethods().followUser(
                                      (snap.data as dynamic)['uid'], widget.uid)
                              : (snap.data as dynamic)['followers']
                                      .contains(currentUserId)
                                  ? FirestoreMethods().followUser(currentUserId,
                                      (snap.data as dynamic)['uid'])
                                  : null;
                          Navigator.pop(context);
                        },
                        title: Text(
                          !isFollowing ? 'Unfollow' : 'Remove',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        title: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ));
    }

    return Scaffold(
      appBar: AppBar(
        //Todo: be removed after ui finished
        leading: const BackButton(),
        title: Text(widget.username),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.isFollowing = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: MediaQuery.of(context).size.width * 0.15),
                  child: Text(
                    'Followers',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color:
                            widget.isFollowing! ? Colors.grey : Colors.white),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.isFollowing = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: MediaQuery.of(context).size.width * 0.15),
                  child: Text('Following',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: !widget.isFollowing!
                              ? Colors.grey
                              : Colors.white)),
                ),
              ),
            ],
          ),
          Divider(
            indent: !widget.isFollowing!
                ? 0
                : MediaQuery.of(context).size.width * 0.5,
            endIndent: widget.isFollowing!
                ? 0
                : MediaQuery.of(context).size.width * 0.5,
            thickness: 2,
            color: Colors.white,
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                int numberOfFollowers = widget.isFollowing!
                    ? (snap.data! as dynamic)['following'].length
                    : (snap.data! as dynamic)['followers'].length;
                return Expanded(
                  child: ListView.builder(
                      itemCount: numberOfFollowers,
                      itemBuilder: (context, index) {
                        String uid = widget.isFollowing!
                            ? (snap.data! as dynamic)['following'][index]
                            : (snap.data! as dynamic)['followers'][index];
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .snapshots(),
                            builder: (context, snapshot1) {
                              if (snapshot1.hasData) {
                                return Container(
                                  height: 75,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 30),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(
                                                      uid: (snapshot1.data!
                                                          as dynamic)['uid']),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      (snapshot1.data
                                                              as dynamic)[
                                                          'photoUrl']),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Text((snapshot1.data!
                                                as dynamic)['username']),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: isOwnProfile
                                              ? widget.isFollowing!
                                                  ? FollowButton(
                                                      function: () {
                                                        alert(
                                                          isFollowing: false,
                                                          snap: snap,
                                                          index: index,
                                                        );
                                                      },
                                                      btnWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      backgroundColor:
                                                          Colors.black,
                                                      borderColor: Colors.grey,
                                                      text: 'Following',
                                                      textColor: Colors.white)
                                                  : FollowButton(
                                                      function: () {
                                                        alert(
                                                            isFollowing: true,
                                                            index: index,
                                                            snap: snapshot1);
                                                      },
                                                      btnWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      backgroundColor:
                                                          Colors.black,
                                                      borderColor: Colors.grey,
                                                      text: 'Remove',
                                                      textColor: Colors.white)
                                              : (snapshot1.data
                                                          as dynamic)['uid'] !=
                                                      currentUserId
                                                  ? (snapshot1.data as dynamic)[
                                                              'followers']
                                                          .contains(
                                                              currentUserId)
                                                      ? FollowButton(
                                                          function: () {
                                                            alert(
                                                                isFollowing:
                                                                    false,
                                                                snap: snapshot1,
                                                                index: index);
                                                          },
                                                          btnWidth:
                                                              MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                  0.2,
                                                          backgroundColor:
                                                              Colors.black,
                                                          borderColor:
                                                              Colors.grey,
                                                          text: 'Following',
                                                          textColor: Colors.white)
                                                      : FollowButton(
                                                          function: () {
                                                            FirestoreMethods()
                                                                .followUser(
                                                                    currentUserId,
                                                                    (snapshot1.data
                                                                            as dynamic)[
                                                                        'uid']);
                                                          },
                                                          btnWidth: MediaQuery.of(context).size.width * 0.2,
                                                          backgroundColor: Colors.blue,
                                                          borderColor: Colors.black,
                                                          text: 'Follow',
                                                          textColor: Colors.white)
                                                  : const SizedBox.shrink(),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            });
                      }),
                );
              }),
        ],
      ),
    );
  }
}
