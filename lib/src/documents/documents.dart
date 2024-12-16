import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:themis/src/documents/document.dart';
import 'package:themis/src/documents/documents_controller.dart';
import 'package:themis/src/documents/forms/demand_letter.dart';

class Documents extends StatefulWidget {
  const Documents({super.key});

  static const routeName = '/documents';

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Ensure that the fetchUserDocuments() call happens after the widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final documentsController =
          Provider.of<DocumentsController>(context, listen: false);
      documentsController.fetchUserDocuments();
      documentsController.filterDocuments('');
    });

    _searchController.addListener(() {
      final documentsController =
          Provider.of<DocumentsController>(context, listen: false);
      documentsController.filterDocuments(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentsController = Provider.of<DocumentsController>(context);

    return Scaffold(
      body: documentsController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Document',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DocumentCard(
                      title: 'Demand Letter',
                      icon: Icons.document_scanner,
                      onTap: () =>
                          Navigator.pushNamed(context, DemandLetter.routeName)),
                  DocumentCard(
                      title: 'Affidavit',
                      icon: Icons.assignment,
                      onTap: () => null),
                  DocumentCard(
                      title: 'Contractor Agreement',
                      icon: Icons.business,
                      onTap: () => null),
                  const SizedBox(height: 20),
                  const Text(
                    'Search Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Documents',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: documentsController.filteredDocuments.isEmpty
                        ? const Center(child: Text('No documents found.'))
                        : SizedBox.expand(
                            child: DataTable(
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text('Delete')),
                                DataColumn(label: Text('Document Name')),
                                DataColumn(label: Text('Timestamp')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: documentsController.filteredDocuments
                                  .map<DataRow>((document) {
                                return DataRow(cells: [
                                  DataCell(IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await documentsController
                                          .deleteDocument(document['id']);
                                    },
                                  )),
                                  DataCell(
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Document(
                                                documentId: document['id']),
                                          ),
                                        );
                                      },
                                      child:
                                          Text(document['title'] ?? 'Untitled'),
                                    ),
                                  ),
                                  DataCell(Text(
                                    document['timestamp'] != null
                                        ? document['timestamp']
                                            .toDate()
                                            .toString()
                                        : 'N/A',
                                  )),
                                  DataCell(
                                    GestureDetector(
                                      onTap: () {
                                        // Placeholder for status handling
                                      },
                                      child: Chip(
                                        label: Text(
                                          document['status'] ?? 'Draft',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        backgroundColor:
                                            Colors.deepPurpleAccent,
                                      ),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DocumentCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
