import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost, String postId) async {
    Reference _ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if (isPost) {
      _ref = _ref.child(postId);
    }

    UploadTask uploadTask = _ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> deleteImage(userId, postId) async {
    var res = '';
    try {
      Reference _ref =
          _storage.ref().child('posts').child(userId).child(postId);
      _ref.delete();
      res = 'Success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

//   Future<List<String>> getProfileDetails(userId, postId) async {
//     List userDetails = [];
//     var res = '';
//     try {
//      QuerySnapshot<Map<String, dynamic>> snap= _storage.;
//       res = 'Success';
//     } catch (e) {
//       res = e.toString();
//     }
//     return res;
//   }
}
