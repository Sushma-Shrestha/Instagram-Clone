import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String username;
  final String bio;
  final List followers;
  final List following;
  final String photoUrl;
  final List messageNumber;
  User(
      {required this.uid,
      required this.email,
      required this.username,
      this.bio = '',
      required this.followers,
      required this.following,
      required this.photoUrl,
      required this.messageNumber});

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'uid': uid,
        'bio': bio,
        'followers': followers,
        'following': following,
        'photoUrl': photoUrl,
        'messageNumber': messageNumber
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);
    return User(
        uid: snapshot['uid'],
        email: snapshot['email'],
        username: snapshot['username'],
        bio: snapshot['bio'],
        followers: snapshot['followers'],
        following: snapshot['following'],
        photoUrl: snapshot['photoUrl'],
        messageNumber: snapshot['messageNumber']);
  }
}
