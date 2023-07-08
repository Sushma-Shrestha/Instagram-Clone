import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/messages_model.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:uuid/uuid.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String description,
    Uint8List _file,
    String uid,
    String username,
    String profileUrl,
  ) async {
    String res = 'Some error occured!';
    try {
      String postId = const Uuid().v1();
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('posts', _file, true, postId);

      Post post = Post(
          uid: uid,
          description: description,
          username: username,
          postId: postId,
          datePublished: DateTime.now(),
          profileImage: profileUrl,
          postImage: photoUrl,
          likes: [],
          favourites: []);

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = 'Success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> sendMessage(
    String userId,
    String friendId,
    String sendMessage,
    String friendUrl,
    String userUrl,
    String friendName,
    String username,
  ) async {
    String res = 'Some error occured!';
    String messageId = const Uuid().v1();
    try {
      Message messageToSend = Message(
          message: sendMessage,
          type: 'S',
          messagedTime: DateTime.now(),
          messageId: messageId);

      Message messageToReceive = Message(
          message: sendMessage,
          type: 'R',
          messagedTime: DateTime.now(),
          messageId: messageId);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('messages')
          .doc(friendId)
          .collection('messageList')
          .doc(messageId)
          .set(messageToSend.toJson());

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('messages')
          .doc(friendId)
          .set({
        'userId': userId,
        'friendId': friendId,
        'friendUrl': friendUrl,
        'friendName': friendName,
        'lastMessagedTime': DateTime.now()
      });

      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('messages')
          .doc(userId)
          .collection('messageList')
          .doc(messageId)
          .set(messageToReceive.toJson());

      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('messages')
          .doc(userId)
          .set({
        'userId': friendId,
        'friendId': userId,
        'friendUrl': userUrl,
        'friendName': username,
        'lastMessagedTime': DateTime.now(),
        'unreadMessages': true
      });
      await _firestore.collection('users').doc(friendId).update({
        'messageNumber': FieldValue.arrayUnion([userId])
      });
      res = 'Success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> removeMessageCount(String friendId, String userId) async {
    await _firestore.collection('users').doc(friendId).update({
      'messageNumber': FieldValue.arrayRemove([userId])
    });
  }

  Future<void> unsendMessage(
      String userId, String friendId, String messageId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('messages')
          .doc(friendId)
          .collection('messageList')
          .doc(messageId)
          .delete();
      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('messages')
          .doc(userId)
          .collection('messageList')
          .doc(messageId)
          .delete();
    } catch (e) {
      e.toString();
    }
  }

  Future<void> likePost(
      String postId, String uid, List likes, bool isIcon) async {
    try {
      if (likes.contains(uid) && isIcon) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      e.toString();
    }
  }

  Future<void> addToFavorite(String uid, favourites, String postId) async {
    try {
      if (favourites.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'favourites': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'favourites': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      e.toString();
    }
  }

  Future<User> getUserData(String userId) async {
    User user;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      user = User.fromSnap(snapshot);
    } catch (e) {
      e.toString();
      user = User(
          uid: '',
          email: '',
          username: '',
          bio: '',
          followers: [],
          following: [],
          photoUrl: '',
          messageNumber: []);
    }
    return user;
  }

  Future<String> postComment(String postId, String comment, String username,
      String uid, String profileUrl) async {
    var res = 'Some error occured';
    try {
      if (comment.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'postId': postId,
          'commentId': commentId,
          'comment': comment,
          'username': username,
          'uid': uid,
          'profileUrl': profileUrl,
          'datePublished': DateTime.now(),
          'likes': [],
        });
        res = 'Success';
      } else {
        res = 'Write some comment first';
      }
    } catch (e) {
      res = (e.toString());
    }
    return res;
  }

  Future<void> likeComment(
      String postId, String uid, List likes, String commentId) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      e.toString();
    }
  }

  Future<String> deletePost(String postId, String uid) async {
    var res = 'Some error occured!';
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'Success';
      res = await StorageMethods().deleteImage(uid, postId);
    } catch (e) {
      res = (e.toString());
    }
    return res;
  }

  Future<String> reportPost(String postId, String uid, String username) async {
    var res = 'Some error occured!';
    try {
      _firestore.collection('reports').doc(postId).set({
        'reporterId': uid,
        'reporterName': username,
        'postId': postId,
        'reportedTime': DateTime.now(),
      });
      res = 'Post reported successfully!';
    } catch (e) {
      res = (e.toString());
    }
    return res;
  }

  Future<String> followUser(String uid, String followId) async {
    var res = 'Some error occured!';
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(uid).get();
      List following = (snapshot.data()! as dynamic)['following'];
      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });
      }
      res = 'Success';
    } catch (e) {
      res = (e.toString());
    }
    return res;
  }
}
