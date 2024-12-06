import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_management_project/services/remote/authentication_service.dart';
import 'package:proj_management_project/services/remote/firestore_service.dart';

class AuthenticationRepository {
  final AuthenticationService _authService;
  final FirestoreService _firestoreService;

  AuthenticationRepository(this._authService, this._firestoreService);

  Future<User?> signIn(String email, String password) async {
    return await _authService.signInUser(email, password);
  }

  Future<User?> signUp(String email, String password, String fullName) async {
    final user = await _authService.signUpUser(email, password);
    if (user != null) {
      await _firestoreService.createUserRecord(
        userId: user.uid,
        email: email,
        fullName: fullName,
      );
    }
    return user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
