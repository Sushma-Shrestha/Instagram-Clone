import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/models/user_model.dart' as users;
import 'package:instagram_clone/screens/screens.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class PostCard extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final snap;
  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  bool isShelfLiked = false;
  bool isLoading = false;
  int? commentLength;
  late bool isFavourite;

  @override
  void initState() {
    super.initState();
    // getCommentLength();
    if (widget.snap['favourites']
        .contains(FirebaseAuth.instance.currentUser!.uid)) {
      isFavourite = true;
    } else {
      isFavourite = false;
    }
  }

  // Future<void> getCommentLength() async {
  //   print('suri');

  //   print(widget.snap['postId']);
  //   commentLength = await FirebaseFirestore.instance
  //       .collection('posts')
  //       .doc(widget.snap['postId'])
  //       .collection('comments')
  //       .snapshots()
  //       .length;
  //   setState(() {
  //     print(commentLength);
  //     print(widget.snap['postId']);
  //     print('suri');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final users.User user = Provider.of<UserProvider>(context).getUser;

    final width = MediaQuery.of(context).size.width;
    bool checkShelfLiked() {
      if (widget.snap['likes'].contains(user.uid)) {
        isShelfLiked = true;
        return true;
      } else {
        isShelfLiked = false;
        return false;
      }
    }

    return Container(
      decoration: BoxDecoration(
          color: mobileBackgroundColor,
          border: Border.all(
              color: width > webScreenSize
                  ? secondaryColor
                  : mobileBackgroundColor)),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(uid: widget.snap['uid']),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: CachedNetworkImageProvider(
                            widget.snap['profileImage']),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => Container(
                              margin: width > webScreenSize
                                  ? EdgeInsets.symmetric(
                                      horizontal: width * 0.35)
                                  : null,
                              child: Dialog(
                                backgroundColor: Colors.grey[700],
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(10),
                                  children: [
                                    widget.snap['uid'] == user.uid
                                        ? ListTile(
                                            title: const Text(
                                              'Delete this post',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              showDialog(
                                                context: context,
                                                builder: (context) => Container(
                                                  margin: width > webScreenSize
                                                      ? EdgeInsets.symmetric(
                                                          horizontal:
                                                              width * 0.35)
                                                      : null,
                                                  child: Dialog(
                                                    child: ListView(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      shrinkWrap: true,
                                                      children: [
                                                        const Text(
                                                          'Delete this post?',
                                                          style: TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        const Text(
                                                          'Post once deleted are not reversible. Are you sure you want to delete this post?',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        const Divider(
                                                          color: Colors.grey,
                                                        ),
                                                        ListTile(
                                                          onTap: () async {
                                                            setState(() {
                                                              isLoading = true;
                                                            });
                                                            var res = await FirestoreMethods()
                                                                .deletePost(
                                                                    widget.snap[
                                                                        'postId'],
                                                                    user.uid);
                                                            Navigator.pop(
                                                                context);

                                                            if (res ==
                                                                'Success') {
                                                              showSnackBar(
                                                                  'Post deleted',
                                                                  context);
                                                            } else {
                                                              showSnackBar(
                                                                  res, context);
                                                            }

                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          },
                                                          title: isLoading
                                                              ? const Center(
                                                                  child: CircularProgressIndicator(
                                                                      color:
                                                                          primaryColor),
                                                                )
                                                              : const Text(
                                                                  'Delete',
                                                                  style: TextStyle(
                                                                      color:
                                                                          blueColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                        ),
                                                        const Divider(
                                                          color: Colors.grey,
                                                        ),
                                                        ListTile(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          title: const Text(
                                                            'Dont\'t delete',
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColor),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : ListTile(
                                            title: const Text(
                                              'Report this post',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onTap: () async {
                                              var res = await FirestoreMethods()
                                                  .reportPost(
                                                      widget.snap['postId'],
                                                      user.uid,
                                                      user.email +
                                                          ' ' +
                                                          user.uid);
                                              Navigator.pop(context);
                                              showSnackBar(res, context);
                                            },
                                          ),
                                    const Divider(
                                      color: Colors.grey,
                                    ),
                                    ListTile(
                                      title: const Text('Cancel'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ));
                  },
                  icon: const Icon(Icons.more_vert),
                )
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                  widget.snap['postId'], user.uid, widget.snap['likes'], false);
              setState(() {
                widget.snap['likes'].contains(user.uid)
                    ? isLikeAnimating = true
                    : false;
              });
            },
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                height: width > webScreenSize ? width * 0.4 : width,
                width: MediaQuery.of(context).size.width,
                child: CachedNetworkImage(
                  imageUrl: widget.snap['postImage'],
                  fit: BoxFit.cover,
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLikeAnimating ? 1 : 0,
                child: LikeAnimation(
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 120,
                  ),
                  isAnimating: isLikeAnimating,
                  duration: const Duration(milliseconds: 400),
                  onEnd: () {
                    setState(() {
                      isLikeAnimating = false;
                    });
                  },
                ),
              ),
            ]),
          ),
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                    onPressed: () async {
                      await FirestoreMethods().likePost(widget.snap['postId'],
                          user.uid, widget.snap['likes'], true);
                      setState(() {
                        if (widget.snap['likes'].contains(user.uid)) {
                          isShelfLiked = true;
                        } else {
                          isShelfLiked = false;
                        }
                      });
                    },
                    icon: checkShelfLiked()
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(Icons.favorite_border)),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(snap: widget.snap),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.comment,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.send,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {
                      FirestoreMethods().addToFavorite(user.uid,
                          widget.snap['favourites'], widget.snap['postId']);
                      setState(() {
                        if (isFavourite == true) {
                          isFavourite = false;
                        } else {
                          isFavourite = true;
                          showSnackBar('Added to favourites!', context);
                        }
                      });
                    },
                    icon: Icon(
                      isFavourite ? Icons.bookmark : Icons.bookmark_border,
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    widget.snap['likes'].length == 0
                        ? ''
                        : widget.snap['likes'].length.toString() + ' likes',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                        style: const TextStyle(
                          color: primaryColor,
                        ),
                        children: [
                          TextSpan(
                            text: widget.snap['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '   ${widget.snap['description']}',
                          ),
                        ]),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(top: 4),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.snap['postId'])
                          .collection('comments')
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.hasError ||
                            snapshot.data!.docs.isEmpty) {
                          return const Text(
                            'No comments',
                            style:
                                TextStyle(fontSize: 16, color: secondaryColor),
                          );
                        }
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    CommentScreen(snap: widget.snap),
                              ),
                            );
                          },
                          child: Text(
                            'View all ${snapshot.data!.docs.length} comments',
                            style: const TextStyle(
                                fontSize: 16, color: secondaryColor),
                          ),
                        );
                      },
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}








/*class PostCard extends StatelessWidget {
  const PostCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue,
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    user.username,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.more_vert))
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        AspectRatio(
          aspectRatio: 5 / 7,
          child: Image(
            image: NetworkImage(user.photoUrl),
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.favorite_outline,
                    size: 30,
                  ),
                  SizedBox(width: 15),
                  Icon(
                    Mdi.comment,
                    size: 30,
                  ),
                  SizedBox(width: 15),
                  Icon(
                    Icons.share_rounded,
                    size: 30,
                  ),
                ],
              ),
              Row(
                children: const [Icon(Icons.add_to_drive)],
              )
            ],
          ),
        )
      ],
    );
  }
}
*/
