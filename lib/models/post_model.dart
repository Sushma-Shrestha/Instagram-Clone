import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String description;
  final String username;
  final String postId;
  final DateTime datePublished;
  final List likes;
  final String profileImage;
  final String postImage;
  final List favourites;

  Post(
      {required this.uid,
      required this.description,
      required this.username,
      required this.postId,
      required this.datePublished,
      required this.likes,
      required this.profileImage,
      required this.postImage,
      required this.favourites});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'description': description,
        'username': username,
        'postId': postId,
        'datePublished': datePublished,
        'likes': likes,
        'profileImage': profileImage,
        'postImage': postImage,
        'favourites': favourites
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);
    return Post(
        uid: snapshot['uid'],
        description: snapshot['description'],
        username: snapshot['username'],
        postId: snapshot['postId'],
        datePublished: snapshot['datePublished'],
        likes: snapshot['likes'],
        profileImage: snapshot['profileImage'],
        postImage: snapshot['postImage'],
        favourites: snapshot['favourites']);
  }
}
