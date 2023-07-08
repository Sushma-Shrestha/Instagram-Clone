import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/comment_card.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CommentScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final snap;
  const CommentScreen({Key? key, required this.snap}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final commentController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: const Text('Comments'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.snap['postId'])
              .collection('comments')
              .orderBy('datePublished', descending: true)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: ((context, index) {
                return CommentCard(
                  snap: snapshot.data!.docs[index].data(),
                );
              }),
            );
          },
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 1),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: TextField(
                    maxLines: 3,
                    style: const TextStyle(fontSize: 18),
                    scribbleEnabled: false,
                    controller: commentController,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        hintText: 'Comment as ${user.username}'),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  var res = await FirestoreMethods().postComment(
                      widget.snap['postId'],
                      commentController.text,
                      user.username,
                      user.uid,
                      user.photoUrl);

                  if (res != 'Success') {
                    showSnackBar(res, context);
                  } else {
                    showSnackBar('Comment posted!', context);
                    commentController.text = '';
                  }
                },
                child: const Text(
                  'Post',
                  style: TextStyle(color: blueColor, fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
