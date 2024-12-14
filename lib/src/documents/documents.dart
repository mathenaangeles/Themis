import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:themis/src/settings/settings_controller.dart';
// import 'package:themis/src/settings/settings_view.dart';
// import 'settings/settings_view.dart';
// import 'sample_item_details_view.dart';

class Documents extends StatelessWidget {
  const Documents({super.key});

  static const routeName = '/documents';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page
              // Navigator.restorablePushNamed(context, SettingsView(controller: SettingsController(_settingsService)).routeName);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('documents').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items found.'));
          }

          // If data exists, display the list
          var items = snapshot.data!.docs;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              var item = items[index];
              var itemId = item.id;
              var itemTitle =
                  item['title']; // Assuming each document has a 'title' field

              return ListTile(
                title: Text(itemTitle),
                leading: const CircleAvatar(
                  foregroundImage: AssetImage('assets/images/flutter_logo.png'),
                ),
                onTap: () {
                  // Navigate to the details page with the selected item
                  // Navigator.restorablePushNamed(
                  //   context,
                  //   const SampleItemListView().routeName,
                  // );
                },
              );
            },
          );
        },
      ),
    );
  }
}
