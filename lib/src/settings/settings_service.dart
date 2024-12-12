import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ThemeMode> themeMode() async => ThemeMode.system;

  Future<void> updateThemeMode(ThemeMode theme) async {}

  Future<Map<String, dynamic>> getUserData() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update(updatedData);
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}
