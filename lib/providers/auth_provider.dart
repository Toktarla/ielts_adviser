import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:proj_management_project/services/snackbar_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  User? _user;

  User? get user => _user;

  AuthenticationProvider(
      this.firebaseAuth,
      this.firebaseFirestore,
      );

  void signInUser(String email, String password, BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      Navigator.pushNamedAndRemoveUntil(context, "/StreakTracker",arguments: {
        "userId": firebaseAuth.currentUser?.uid
      },(route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        SnackbarService.showErrorSnackbar(
            message: "No user found for that email");
      } else if (e.code == 'wrong-password') {
        SnackbarService.showErrorSnackbar(
            message: "Wrong password provided for that user");
      } else if (e.message != null &&
          e.message!.contains(
              'The supplied auth credential is incorrect, malformed or has expired')) {
        SnackbarService.showErrorSnackbar(
            message:
            "The supplied auth credential is incorrect, malformed or has expired");
      } else {
        SnackbarService.showErrorSnackbar(message: "Error: ${e.message}");
      }
    } catch (e) {
      SnackbarService.showErrorSnackbar(
          message: "An error occurred: ${e.toString()}");
    }
  }

  void signUpUser(String email, String password, String confirmPassword, String fullName, BuildContext context) async {
    try {
      if (password == confirmPassword) {
        final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        User? emailUser = credential.user;
        await emailUser?.updateDisplayName(fullName.trim());

        _user = emailUser;

        final userDoc =
        await firebaseFirestore.collection('users').doc(user!.uid).get();

        if (!userDoc.exists) {
          String? fcmToken = await FirebaseMessaging.instance.getToken();

          await firebaseFirestore.collection('users').doc(_user!.uid).set({
            'addtime': Timestamp.now(),
            'email': _user!.email,
            'fcmToken': fcmToken ?? '',
            'userId': _user!.uid,
            'name': fullName,
          });
        }
      } else {
        SnackbarService.showErrorSnackbar(message: "Passwords don't match");
      }
      Navigator.pushNamedAndRemoveUntil(context, "/VerifyEmail", (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        SnackbarService.showErrorSnackbar(message: "No user found for that email");
      } else if (e.code == "email-already-in-use") {
        SnackbarService.showErrorSnackbar(message: "This email already exists. Try another.");
      }
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      notifyListeners();
    } on Exception catch (_) {
      print('Exception during sign out');
    }
  }
}