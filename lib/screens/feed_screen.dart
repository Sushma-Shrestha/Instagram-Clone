import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:mdi/mdi.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'screens.dart';
import 'package:instagram_clone/widgets/widgets.dart';
import 'package:instagram_clone/models/user_model.dart' as users;

class FeedScreen extends StatefulWidget {
  final bool isProfileFeed;
  final bool isExploreFeed;
  final String? uid;
  final int itemNumber;
  final bool isFav;
  const FeedScreen({
    Key? key,
    this.isProfileFeed = false,
    this.uid,
    this.itemNumber = 1,
    this.isExploreFeed = false,
    this.isFav = false,
  }) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late int messageCount;
  @override
  void initState() {
    super.initState();
    UserProvider().refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final ScrollController _controller = width > webScreenSize
        ? ScrollController(
            initialScrollOffset:
                width * 0.4 * widget.itemNumber + (240 * widget.itemNumber))
        : widget.itemNumber == 0
            ? ScrollController(
                initialScrollOffset:
                    width * widget.itemNumber + (235 * widget.itemNumber))
            : ScrollController(
                initialScrollOffset:
                    width * widget.itemNumber + (215 * widget.itemNumber));
    final users.User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: MediaQuery.of(context).size.width > webScreenSize
          ? webBackgroundColor
          : mobileBackgroundColor,
      appBar: widget.isProfileFeed || widget.isExploreFeed
          ? AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: widget.isExploreFeed
                    ? const Text('Explore')
                    : widget.isFav
                        ? const Text('Favourites')
                        : const Text('Posts'),
              ),
            )
          : MediaQuery.of(context).size.width < webScreenSize
              ? AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: mobileBackgroundColor,
                  centerTitle: false,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SvgPicture.asset(
                      'Assets/ic_instagram.svg',
                      color: Colors.white,
                      height: 32,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(.0),
                      child: Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) =>
                                      const MessagesScreen()));
                            },
                            icon: const Icon(
                              Mdi.facebookMessenger,
                            ),
                          ),
                          Positioned(
                            left: 25,
                            child: user.messageNumber.isNotEmpty
                                ? Container(
                                    child: Center(
                                      child: Text(
                                        user.messageNumber.length.toString(),
                                      ),
                                    ),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    height: 18,
                                    width: 18,
                                  )
                                : const SizedBox.shrink(),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : null,
      body: StreamBuilder(
        stream: !widget.isExploreFeed && !widget.isProfileFeed
            ? FirebaseFirestore.instance
                .collection('posts')
                .orderBy('datePublished', descending: true)
                .snapshots()
            : widget.isProfileFeed
                ? widget.isFav
                    ? FirebaseFirestore.instance
                        .collection('posts')
                        .where('favourites', arrayContains: widget.uid)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('posts')
                        .where('uid', isEqualTo: widget.uid)
                        .orderBy('datePublished', descending: true)
                        .snapshots()
                : FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              controller: widget.isProfileFeed || widget.isExploreFeed
                  ? _controller
                  : ScrollController(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: ((context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: width > webScreenSize ? width * 0.3 : 0,
                      vertical: width > webScreenSize ? 15 : 0),
                  child: PostCard(
                    snap: snapshot.data!.docs[index].data(),
                  ),
                );
              }),
            );
          }
        },
      ),
    );
  }
}


     // Navigator.of(context).push(PageRouteBuilder(
                          //     opaque: true,
                          //     transitionDuration: const Duration(milliseconds: 500),
                          //     pageBuilder: (BuildContext context, _, __) {
                          //       return const MessagesScreen();
                          //     },
                          //     transitionsBuilder: (_, Animation<double> animation,
                          //         __, Widget child) {
                          //       return SlideTransition(
                          //         child: child,
                          //         position: Tween<Offset>(
                          //           begin: const Offset(5, 0),
                          //           end: Offset.zero,
                          //         ).animate(animation),
                          //       );
                          //     }));
