import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_management_project/utils/helpers/snackbar_helper.dart';

class ErrorHandler {
  static void handleAuthError(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      SnackbarHelper.showErrorSnackbar(message: "No user found for that email");
    } else if (e.code == 'wrong-password') {
      SnackbarHelper.showErrorSnackbar(message: "Wrong password provided");
    } else if (e.code == 'email-already-in-use') {
      SnackbarHelper.showErrorSnackbar(message: "This email already exists");
    } else {
      SnackbarHelper.showErrorSnackbar(message: "Error: ${e.message}");
    }
  }
}