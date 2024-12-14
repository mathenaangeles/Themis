import 'authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationController {
  final AuthenticationService _authenticationService = AuthenticationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> register({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final userCredential =
          await _authenticationService.registerWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential != null) {
        String uid = userCredential.user!.uid;
        await _firestore.collection('users').doc(uid).set(userData);
        await _authenticationService.loginWithEmailAndPassword(email, password);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(
      {required String email, required String password}) async {
    try {
      await _authenticationService.loginWithEmailAndPassword(email, password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> isLoggedIn() async {
    final user = _authenticationService.getCurrentUser();
    return user != null;
  }

  User? getCurrentUser() {
    return _authenticationService.getCurrentUser();
  }

  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    try {
      User? user = _authenticationService.getCurrentUser();
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authenticationService.signOut();
  }
}
