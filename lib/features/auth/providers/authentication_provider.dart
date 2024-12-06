import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proj_management_project/utils/error/error_handler.dart';
import 'package:proj_management_project/utils/helpers/snackbar_helper.dart';

import '../repositories/authentication_repository.dart';

class AuthenticationProvider extends ChangeNotifier {
  final AuthenticationRepository _authRepository;

  User? _user;
  User? get user => _user;

  AuthenticationProvider(this._authRepository);

  Future<void> signIn(String email, String password, BuildContext context) async {
    try {
      _user = await _authRepository.signIn(email, password);
      if (_user != null) {
        Navigator.pushNamedAndRemoveUntil(context, "/StreakTracker", arguments: {
          "userId": _user!.uid,
        }, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      ErrorHandler.handleAuthError(e);
    } catch (e) {
      SnackbarHelper.showErrorSnackbar(message: "An error occurred: $e");
    }
  }

  Future<void> signUp(
      String email, String password, String confirmPassword, String fullName, BuildContext context) async {
    try {
      if (password == confirmPassword) {
        _user = await _authRepository.signUp(email, password, fullName);
        if (_user != null) {
          Navigator.pushNamedAndRemoveUntil(context, "/VerifyEmail", (route) => false);
        }
      } else {
        SnackbarHelper.showErrorSnackbar(message: "Passwords don't match");
      }
    } on FirebaseAuthException catch (e) {
      ErrorHandler.handleAuthError(e);
    } catch (e) {
      SnackbarHelper.showErrorSnackbar(message: "An error occurred: $e");
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _authRepository.signOut();
      _user = null;
      Navigator.pushNamedAndRemoveUntil(context, "/Login", (route) => false);
    } catch (e) {
      print("Error during sign-out: $e");
    }
  }
}
