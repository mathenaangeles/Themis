import 'package:cloud_firestore/cloud_firestore.dart';

class DirectoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getLawyers() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('is_lawyer', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> lawyers = [];

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;
        DocumentSnapshot userDetails =
            await _firestore.collection('users').doc(userId).get();
        lawyers.add({
          'first_name': userDetails['first_name'],
          'last_name': userDetails['last_name'],
          'phone': userDetails['phone'],
          'address': userDetails['address'],
          'tags': userDetails['tags'],
        });
      }
      return lawyers;
    } catch (e) {
      print('Error fetching lawyers: $e');
      return [];
    }
  }
}
