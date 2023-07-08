import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/models/user_model.dart' as user_model;
import 'package:instagram_clone/utils/utils.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<user_model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return user_model.User.fromSnap(snap);
  }

  Future<String> signUpUser(
      {required String email,
      required String username,
      required String password,
      required Uint8List file,
      bool isGoogle = false}) async {
    String res = 'Some error occured!';
    try {
      if (email.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false, '');

        user_model.User user = user_model.User(
            uid: userCredential.user!.uid,
            username: username,
            email: email,
            bio: '',
            followers: [],
            following: [],
            photoUrl: photoUrl,
            messageNumber: []);

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toJson());
        res = 'Success';
      } else {
        res = 'Please fill all the fields!';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'email-already-in-use') {
        res = 'Email is already in used!';
      } else if (err.code == 'weak-password') {
        res = 'Use atleast 6 character password!';
      } else {
        res = err.toString();
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //email-already-in-use
  //weak-password\
  Future<User?> signInWithGoogle({required BuildContext context}) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user;

      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
      }

      return user;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  Future<String> resetPassword(String email) async {
    String res = 'Some error occured';
    try {
      await _auth.sendPasswordResetEmail(email: email);

      res = 'Success';
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        res = 'No user registered with given email.';
      } else if (err.code == 'invalid-email') {
        res = 'Not a valid email address';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> changePassword(
      String email, String currentPassword, String newPassword) async {
    String res = 'Some error occured';
    try {
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        res = 'Fill the empty fields.';
      } else {
        AuthCredential credential = EmailAuthProvider.credential(
            email: email, password: currentPassword);
        var user = _auth.currentUser!;
        await user.reauthenticateWithCredential(credential).then((value) {
          user.updatePassword(newPassword);
          res = 'Success';
        });
      }
    } on FirebaseAuthException catch (err) {
      res = err.code.toString();
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> logInUser(
      {required String email, required String password}) async {
    String res = 'Some error occured!';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      } else {
        res = 'Please enter all the fields!';
      }
    } on FirebaseAuthException catch (err) {
      //invalid-email
      if (err.code == 'invalid-email') {
        res = 'Invalid email address!';
      }
      //user-not-found
      else if (err.code == 'user-not-found') {
        res = 'User not found!';
      }
      //wrong-password
      else if (err.code == 'wrong-password') {
        res = 'Wrong password!';
      } else {
        res = err.code;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> logOutUser() async {
    await _auth.signOut();
    GoogleSignIn().signOut();
  }
}
