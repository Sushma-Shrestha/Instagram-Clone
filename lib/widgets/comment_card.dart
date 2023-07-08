import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class CommentCard extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final snap;
  const CommentCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isLiked = false;
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    bool checkShelfLiked() {
      if (widget.snap['likes'].contains(user.uid)) {
        isLiked = true;
        return true;
      } else {
        isLiked = false;
        return false;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                CachedNetworkImageProvider(widget.snap['profileUrl']),
            radius: 18,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: widget.snap['username'] + ' ',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        TextSpan(
                          text: widget.snap['comment'],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(
                          DateFormat.yMMMd()
                              .format(widget.snap['datePublished'].toDate()),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                        widget.snap['likes'].length != 0 &&
                                widget.snap['likes'].length != 1
                            ? Text(
                                '  ${widget.snap['likes'].length.toString()} likes',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w400),
                              )
                            : const SizedBox.shrink(),
                        widget.snap['likes'].length == 1
                            ? Text(
                                '  ${widget.snap['likes'].length.toString()} like',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w400),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  )
                ]),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                splashColor: Colors.transparent,
                onPressed: () {
                  FirestoreMethods().likeComment(
                    widget.snap['postId'],
                    user.uid,
                    widget.snap['likes'],
                    widget.snap['commentId'],
                  );
                  setState(() {
                    if (widget.snap['likes'].contains(user.uid)) {
                      isLiked = true;
                    } else {
                      isLiked = false;
                    }
                  });
                },
                icon: checkShelfLiked()
                    ? const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                    : const Icon(Icons.favorite_border),
              ),
            ),
          )
        ],
      ),
    );
  }
}
