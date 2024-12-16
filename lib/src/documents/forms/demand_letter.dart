import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:themis/src/documents/documents_controller.dart';
import 'package:themis/src/authentication/authentication_controller.dart';

class DemandLetter extends StatefulWidget {
  static const routeName = '/demand_letter';

  @override
  State<DemandLetter> createState() => _DemandLetterState();
}

class _DemandLetterState extends State<DemandLetter> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _documentTitleController =
      TextEditingController();
  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _recipientAddressController =
      TextEditingController();
  final TextEditingController _amountDueController = TextEditingController();
  final TextEditingController _additionalDetailsController =
      TextEditingController();

  String _userName = '';
  String _userAddress = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserDetails();
  }

  Future<void> _loadCurrentUserDetails() async {
    final authController =
        Provider.of<AuthenticationController>(context, listen: false);
    final userDetails = await authController.getCurrentUserDetails();

    if (userDetails != null) {
      setState(() {
        _userName = userDetails['name'] ?? '[Insert Name Here]';
        _userAddress = userDetails['address'] ?? '[Insert Address Here]';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentController = Provider.of<DocumentsController>(context);

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Demand Letter Explanation Section
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'What is a Demand Letter?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'A demand letter is a formal written request asking someone to fulfill a legal obligation, '
                            'such as paying a debt or returning property. It typically outlines the details of the dispute, '
                            'the requested remedy, and the consequences of failing to comply within a specified timeframe.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Input Form Section
                  Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Document Title'),
                              controller: _documentTitleController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a document title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Recipient Name'),
                              controller: _recipientNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter recipient name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Recipient Address'),
                              controller: _recipientAddressController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter recipient address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Amount Due'),
                              keyboardType: TextInputType.number,
                              controller: _amountDueController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the amount due';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Additional Details'),
                              maxLines: 3,
                              controller: _additionalDetailsController,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  print(_userName);
                                  final documentInformation = '''
                                    From: $_userName, $_userAddress
                                    To: ${_recipientNameController.text}, ${_recipientAddressController.text}
                                    Amount Due: ${_amountDueController.text}
                                    Details: ${_additionalDetailsController.text}
                                  ''';

                                  documentController.generateDemandLetter(
                                    _documentTitleController.text,
                                    documentInformation,
                                  );

                                  if (!documentController.isLoading) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Demand letter generation started'),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text('Generate Demand Letter'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (documentController.generatedDocument.isNotEmpty)
                    Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                        text: documentController
                                            .generatedDocument));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Document copied to clipboard'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    await documentController
                                        .saveGeneratedDocument(
                                      title: _documentTitleController.text,
                                      content:
                                          documentController.generatedDocument,
                                    );
                                  },
                                  child: const Text('Save Document'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 10),
                            SelectableText(
                              documentController.generatedDocument,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (documentController.isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
