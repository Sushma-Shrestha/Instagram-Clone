import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/profile_message_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/models/user_model.dart' as user_model;

class SearchScreen extends StatefulWidget {
  final bool isMessage;
  final String? searchData;

  const SearchScreen({
    Key? key,
    this.isMessage = false,
    this.searchData = '',
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  bool isLoading = false;
  int itemNumber = 0;
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.isMessage ? isShowUsers = true : isShowUsers = false;
      searchController.text = '${widget.searchData}';
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: width < webScreenSize
          ? AppBar(
              leading: isShowUsers
                  ? BackButton(
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          isShowUsers = false;
                          searchController.clear();
                          FocusScope.of(context).unfocus();
                        });
                      },
                    )
                  : null,
              backgroundColor: mobileBackgroundColor,
              title: Container(
                alignment: Alignment.center,
                width: width * 0.9,
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: TextField(
                  style: const TextStyle(fontSize: 18),
                  cursorColor: Colors.white,
                  controller: searchController,
                  textAlignVertical: TextAlignVertical.center,

                  decoration: InputDecoration(
                    focusColor: Colors.white,
                    prefixIconColor: Colors.white,
                    contentPadding: isShowUsers
                        ? const EdgeInsets.only(left: 15)
                        : EdgeInsets.zero,
                    alignLabelWithHint: true,
                    filled: true,
                    prefixIcon: isShowUsers ? null : const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.grey[800],
                    hintText: 'Search',
                  ),
                  // onEditingComplete: () {
                  //   setState(() {
                  //     isShowUsers = true;
                  //   });
                  // },
                  onTap: () {
                    setState(() {
                      isShowUsers = true;
                    });
                  },
                  onChanged: (String data) {
                    setState(() {
                      searchController.text == ''
                          ? isShowUsers == false
                          : isShowUsers = true;
                    });
                  },
                ),
              ),
            )
          : null,
      body: isShowUsers
          ? SearchResult(
              searchController: width > webScreenSize
                  ? widget.searchData!
                  : searchController.text,
              isMessage: widget.isMessage,
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return MasonryGridView.count(
                    padding: EdgeInsets.symmetric(
                        horizontal: width > webScreenSize ? width / 5 : 0,
                        vertical: width > webScreenSize ? 20 : 0),
                    crossAxisCount: 3,
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        itemNumber = index;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FeedScreen(
                                  isExploreFeed: true,
                                  itemNumber: itemNumber,
                                )));
                      },
                      child: Image(
                        fit: BoxFit.cover,
                        image: (CachedNetworkImageProvider(
                            (snapshot.data! as dynamic).docs[index]
                                ['postImage'])),
                      ),
                    ),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    // staggeredTileBuilder: (index) => StaggeredTile.count(
                    //     (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1)
                  );
                }
              }),
    );
  }
}

class SearchResult extends StatefulWidget {
  final bool isMessage;
  final String searchController;
  const SearchResult(
      {Key? key, required this.searchController, this.isMessage = false})
      : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  @override
  Widget build(BuildContext context) {
    final user_model.User user = Provider.of<UserProvider>(context).getUser;
    setState(() {});
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('username'.toLowerCase(),
              isGreaterThanOrEqualTo: widget.searchController)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  !widget.isMessage ||
                          MediaQuery.of(context).size.width > webScreenSize
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              uid: (snapshot.data! as dynamic).docs[index]
                                  ['uid'],
                            ),
                          ),
                        )
                      : Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileMessage(
                                friendId: (snapshot.data! as dynamic)
                                    .docs[index]['uid'],
                                friendPhoto: (snapshot.data! as dynamic)
                                    .docs[index]['photoUrl'],
                                userId: user.uid,
                                userPhoto: user.photoUrl,
                                friendName: (snapshot.data! as dynamic)
                                    .docs[index]['username'],
                                username: user.username,
                              )));
                },
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: CachedNetworkImageProvider(
                      (snapshot.data! as dynamic).docs[index]['photoUrl'],
                    ),
                  ),
                  title:
                      Text((snapshot.data! as dynamic).docs[index]['username']),
                ),
              );
            });
      },
    );
  }
}
