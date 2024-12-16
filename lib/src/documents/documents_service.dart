import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String baseUrl =
      'https://documentgeneratorfunction-sgpv2va7uq-uc.a.run.app';
  Future<String> generateDocument({
    required String documentType,
    required String information,
  }) async {
    try {
      final response = await http.post(Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'documentType': documentType,
            'information': information,
          }));
      if (response.statusCode == 200) {
        return response.body.trim();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (error) {
      throw Exception('Error calling cloud function: $error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchDocumentsForUser(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('Error fetching documents: $e');
      return [];
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('documents')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Error deleting document: $e');
      throw e;
    }
  }
}
