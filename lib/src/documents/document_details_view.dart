import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';

  @override
  Widget build(BuildContext context) {
    final String itemId = ModalRoute.of(context)!.settings.arguments as String;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('documents').doc(itemId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text('Error loading item')));
        }

        if (snapshot.hasData && snapshot.data != null) {
          var itemData = snapshot.data!;
          var itemTitle = itemData['title']; // Get the title from Firestore

          return Scaffold(
            appBar: AppBar(title: Text(itemTitle)),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title: $itemTitle',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('More details about this item can go here.')
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: Text('Item not found')));
      },
    );
  }
}
