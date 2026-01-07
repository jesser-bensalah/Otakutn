import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';




//state, we dont lose info, 
ValueNotifier<AuthService> authServiceNotifier =
    ValueNotifier<AuthService>(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //access to current user
  User? get currentUser => firebaseAuth.currentUser;

  // returns info in order to know the user is connected or not
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Error during sign in: $e');
      return null;
    }
  }

  //create account
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Error during account creation: $e');
      return null;
    }
  }

  //sign out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  //reset password
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  ///update username
  Future<void> updateDisplayName(String displayName) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(displayName);
      await currentUser!.reload();
    }
  }

  //delete account
  // Delete account. Caller must provide the user's current password to reauthenticate.
  Future<void> deleteUser(String password) async {
    final user = currentUser;
    if (user == null) return;

    final email = user.email;
    if (email == null) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'Current user has no email',
      );
    }

    if (password.isEmpty) {
      throw ArgumentError('Password must not be empty.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.delete();
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      // Bubble up Firebase auth errors to the caller after logging.
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // change password
  Future<void> updatePassword(String newPassword, String currentPassword, String email,) async {
 
    final user = currentUser;
    if (user == null) return;

    if (newPassword.isEmpty) {
      throw ArgumentError('New password must not be empty.');
    }

    try {
      await user.updatePassword(newPassword);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }
}
