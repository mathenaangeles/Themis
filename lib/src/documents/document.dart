import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:themis/src/documents/documents_controller.dart';
import 'package:flutter/services.dart';

class Document extends StatefulWidget {
  final String documentId;
  const Document({required this.documentId, super.key});

  @override
  State<Document> createState() => _DocumentState();
}

class _DocumentState extends State<Document> {
  String? selectedLawyerId;

  @override
  Widget build(BuildContext context) {
    final documentsController = Provider.of<DocumentsController>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: documentsController.getDocumentById(widget.documentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading document'));
        }

        final document = snapshot.data ?? {};

        return Scaffold(
          appBar: AppBar(
            title: Text(document['title'] ?? 'Untitled Document'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: documentsController.fetchLawyers(),
                  builder: (context, lawyerSnapshot) {
                    if (lawyerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (lawyerSnapshot.hasError) {
                      return const Center(child: Text('Error loading lawyers'));
                    }
                    final lawyers = lawyerSnapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended Lawyers',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: lawyers.map((lawyer) {
                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.all(2.0),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${lawyer['first_name']} ${lawyer['last_name']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    if (lawyer['tags'] != null)
                                      Wrap(
                                        spacing: 4.0,
                                        children: (lawyer['tags'] as List)
                                            .map((tag) => Chip(
                                                  label: Text(tag),
                                                ))
                                            .toList(),
                                      ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await documentsController
                                            .sendDocumentToLawyer(
                                          widget.documentId,
                                          lawyer['id'],
                                        );

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Document sent to lawyer and status updated.'),
                                          ),
                                        );
                                      },
                                      child: const Text('Send to Lawyer'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Document details and content card
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timestamp and Status Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Underlined timestamp
                            Text(
                              '${document['timestamp']?.toDate()}',
                              style: TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.underline),
                            ),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    document['status'] ?? 'Pending',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor:
                                      document['status'] == 'Pending'
                                          ? Colors.orange
                                          : Colors.purpleAccent,
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                        text: document['content']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Document content copied to clipboard!')),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy Content'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          document['content'] ?? 'No content available',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
