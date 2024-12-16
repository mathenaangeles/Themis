import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'documents_service.dart';

class DocumentsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DocumentsService _documentsService = DocumentsService();
  String _generatedDocument = '';
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _filteredDocuments = [];
  bool _isLoading = false;

  String get generatedDocument => _generatedDocument;
  List<Map<String, dynamic>> get documents => _documents;
  List<Map<String, dynamic>> get filteredDocuments => _filteredDocuments;
  bool get isLoading => _isLoading;

  void generateDemandLetter(
      String documentType, String documentInformation) async {
    if (documentType.isEmpty || documentInformation.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _documentsService.generateDocument(
        documentType: documentType,
        information: documentInformation,
      );
      _generatedDocument = response;
    } catch (error) {
      print('Error generating document: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveGeneratedDocument({
    required String title,
    required String content,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user found.');

      final userCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('documents');

      await userCollection.add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Draft',
      });
    } catch (e) {
      print('Error saving document: $e');
    }
  }

  Future<void> fetchUserDocuments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _documents = await _documentsService.fetchDocumentsForUser(user.uid);
      _filteredDocuments = _documents;
    } catch (error) {
      print('Error fetching user documents: $error');
      _documents = [];
      _filteredDocuments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterDocuments(String query) {
    if (query.isEmpty) {
      _filteredDocuments = _documents;
    } else {
      _filteredDocuments = _documents
          .where((document) =>
              document['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _documentsService.deleteDocument(documentId);
      _documents.removeWhere((document) => document['id'] == documentId);
      fetchUserDocuments();
      notifyListeners();
    } catch (error) {
      print('Error deleting document: $error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLawyers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('is_lawyer', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        var lawyerData = doc.data();
        lawyerData['id'] = doc.id;
        return lawyerData;
      }).toList();
    } catch (e) {
      print("Error fetching lawyers: $e");
      return [];
    }
  }

  Future<void> sendDocumentToLawyer(String documentId, String lawyerId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId == null) {
        print("Error: No user logged in.");
        return;
      }

      print('Sending document $documentId to lawyer $lawyerId');

      DocumentSnapshot docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(documentId)
          .get();

      if (docSnapshot.exists) {
        String documentContent = docSnapshot['content'] ?? '';

        await _firestore
            .collection('users')
            .doc(lawyerId)
            .collection('requests')
            .add({
          'document_id': documentId,
          'status': 'Pending',
          'content': documentContent,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('documents')
            .doc(documentId)
            .update({
          'status': 'Submitted',
        });

        print('Document sent successfully and status updated to submitted');
      } else {
        print('Document not found in the current user\'s collection');
      }
    } catch (e) {
      print("Error sending document to lawyer: $e");
    }
  }

  Future<Map<String, dynamic>> getDocumentById(String documentId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      DocumentSnapshot docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(documentId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        print("Document not found with ID: $documentId");
        throw Exception("Document not found");
      }
    } catch (e) {
      print("Error fetching document by ID: $e");
      return {};
    }
  }
}
