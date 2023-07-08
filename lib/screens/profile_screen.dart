import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/followers_screen.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/screens/profile_message_screen.dart';
import 'package:instagram_clone/screens/setings_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/models/user_model.dart' as users;
import 'package:mdi/mdi.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLength = 0;
  bool isFollowing = false;
  bool isLoading = false;
  int followers = 0;
  int following = 0;
  String username = '';
  String bio = '';
  String photoUrl = '';
  bool doesFollowYou = false;
  int itemNumber = 0;
  bool isFavPage = false;
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      postLength = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      username = userData['username'];
      bio = userData['bio'];
      photoUrl = userData['photoUrl'];
      doesFollowYou = userData['following']
          .contains(FirebaseAuth.instance.currentUser!.uid);

      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final users.User user = Provider.of<UserProvider>(context).getUser;
    var width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: width > webScreenSize
                ? null
                : AppBar(
                    backgroundColor: mobileBackgroundColor,
                    title: Text(username),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingScreen(
                                        email: user.email,
                                      )));
                        },
                        icon: const Icon(Icons.settings),
                      )
                    ],
                  ),
            body: ListView(children: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width * 0.2 : 15,
                    vertical: width > webScreenSize ? 35 : 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(photoUrl),
                          radius: width > webScreenSize ? 70 : 40,
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildStatColumn(postLength, 'Posts'),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) =>
                                                  FollowerScreen(
                                                    username: username,
                                                    isFollowing: false,
                                                    uid: widget.uid,
                                                  )));
                                    },
                                    child:
                                        buildStatColumn(followers, 'Followers'),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    FollowerScreen(
                                                      username: username,
                                                      isFollowing: true,
                                                      uid: widget.uid,
                                                    )));
                                      },
                                      child: buildStatColumn(
                                          following, 'Following'))
                                ],
                              ),
                              FirebaseAuth.instance.currentUser!.uid ==
                                      widget.uid
                                  ? FollowButton(
                                      backgroundColor: mobileBackgroundColor,
                                      text: 'Log out',
                                      borderColor: Colors.grey,
                                      textColor: primaryColor,
                                      function: () async {
                                        await AuthMethods().logOutUser();

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen()),
                                        );
                                      },
                                    )
                                  : isFollowing
                                      ? Row(
                                          children: [
                                            FollowButton(
                                              btnWidth: width > webScreenSize
                                                  ? width * 0.2
                                                  : width * 0.3,
                                              backgroundColor: Colors.black,
                                              text: 'Unfollow',
                                              borderColor: Colors.grey,
                                              textColor: primaryColor,
                                              function: () async {
                                                var res =
                                                    await FirestoreMethods()
                                                        .followUser(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                            widget.uid);
                                                setState(() {
                                                  if (res == 'Success') {
                                                    isFollowing = false;
                                                    followers--;
                                                  }
                                                });
                                              },
                                            ),
                                            FollowButton(
                                                btnWidth: width > webScreenSize
                                                    ? width * 0.2
                                                    : width * 0.3,
                                                backgroundColor: Colors.black,
                                                text: 'Message',
                                                borderColor: Colors.grey,
                                                textColor: primaryColor,
                                                function: () {
                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          ProfileMessage(
                                                        userPhoto:
                                                            user.photoUrl,
                                                        friendPhoto: photoUrl,
                                                        friendId: widget.uid,
                                                        friendName: username,
                                                        userId: FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid,
                                                        username: user.username,
                                                      ),
                                                    ),
                                                  );
                                                })
                                          ],
                                        )
                                      : FollowButton(
                                          backgroundColor: Colors.blue,
                                          text: doesFollowYou
                                              ? 'Follow back'
                                              : 'Follow',
                                          borderColor: Colors.blue,
                                          textColor: Colors.white,
                                          function: () async {
                                            var res = await FirestoreMethods()
                                                .followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    widget.uid);
                                            setState(() {
                                              if (res == 'Success') {
                                                isFollowing = true;
                                                followers++;
                                              }
                                            });
                                          },
                                        ),
                              // FirebaseAuth.instance.currentUser!.uid ==
                              //         widget.uid
                              //     ? const LogoutButton()
                              //     : const SizedBox.shrink()
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        username,
                        style: TextStyle(
                            fontSize: width > webScreenSize ? 20 : null,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top: 1, bottom: 5),
                      child: Text(
                        bio,
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isFavPage = false;
                                  });
                                },
                                child: Icon(
                                  Mdi.grid,
                                  size: 25,
                                  color: isFavPage ? Colors.grey : Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isFavPage = true;
                                  });
                                },
                                child: Icon(
                                  Icons.bookmark,
                                  size: 25,
                                  color: isFavPage ? Colors.white : Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1.5,
                          color: Colors.white,
                          indent: isFavPage ? width * 0.5 : 0,
                          endIndent: isFavPage ? 0 : width * 0.5,
                        )
                      ],
                    ),
                    FutureBuilder(
                      future: isFavPage
                          ? FirebaseFirestore.instance
                              .collection('posts')
                              .where('favourites', arrayContains: widget.uid)
                              .get()
                          : FirebaseFirestore.instance
                              .collection('posts')
                              .where('uid', isEqualTo: widget.uid)
                              .orderBy('datePublished', descending: true)
                              .get(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return snapshot.data!.docs.isNotEmpty
                            ? GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing:
                                      width > webScreenSize ? 25 : 3,
                                  mainAxisSpacing:
                                      width > webScreenSize ? 25 : 3,
                                ),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  DocumentSnapshot snap =
                                      snapshot.data!.docs[index];
                                  return GestureDetector(
                                    onTap: () {
                                      itemNumber = index;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => isFavPage
                                              ? FeedScreen(
                                                  isFav: true,
                                                  isProfileFeed: true,
                                                  uid: widget.uid,
                                                  itemNumber: itemNumber,
                                                )
                                              : FeedScreen(
                                                  isProfileFeed: true,
                                                  uid: widget.uid,
                                                  itemNumber: itemNumber,
                                                ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 200,
                                      width: 200,
                                      color: Colors.white,
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            snap['postImage']),
                                      ),
                                    ),
                                  );
                                })
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 25),
                                child: Center(
                                  child: Text(
                                    isFavPage
                                        ? 'No Favourites posts!'
                                        : 'No posts!',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                      },
                    )
                  ],
                ),
              )
            ]),
          );
  }

  Column buildStatColumn(int stats, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          stats.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            label.toString(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:instagram_clone/providers/user_provider.dart';
// import 'package:instagram_clone/widgets/logout_option.dart';
// import 'package:provider/provider.dart';
// import '../models/user_model.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final User user = Provider.of<UserProvider>(context).getUser;
//     Stream<QuerySnapshot<Map<String, dynamic>>> snap =
//         FirebaseFirestore.instance.collection('posts').snapshots();

//     TextStyle testStyle = const TextStyle(
//       fontSize: 15,
//     );
//     TextStyle testStyle1 =
//         const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundImage: CachedNetworkImageProvider(user.photoUrl),
//                   radius: 50,
//                 ),
//                 const SizedBox(
//                   width: 25,
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Column(
//                             children: [
//                               Text(
//                                 '0',
//                                 style: testStyle1,
//                               ),
//                               Text(
//                                 'Posts',
//                                 style: testStyle,
//                               )
//                             ],
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Column(
//                             children: [
//                               Text(
//                                 user.followers.length.toString(),
//                                 style: testStyle1,
//                               ),
//                               Text(
//                                 'Followers',
//                                 style: testStyle,
//                               )
//                             ],
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Column(
//                             children: [
//                               Text(
//                                 user.following.length.toString(),
//                                 style: testStyle1,
//                               ),
//                               Text(
//                                 'Following',
//                                 style: testStyle,
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       const LogoutButton(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Text(
//               user.username,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(
//               height: 5,
//             ),
//             Text(
//               user.bio,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 17),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             const Divider(
//               thickness: 1,
//               color: Colors.grey,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
