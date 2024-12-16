import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_controller.dart';
import 'package:themis/src/authentication/authentication_controller.dart';

class Advisor extends StatefulWidget {
  const Advisor({super.key});

  @override
  _AdvisorState createState() => _AdvisorState();
}

class _AdvisorState extends State<Advisor> {
  bool _thumbUpClicked = false;
  bool _thumbDownClicked = false;
  String? _selectedPersona;
  bool _isLawyer = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsLawyer();
  }

  Future<void> _checkIfUserIsLawyer() async {
    final authController =
        Provider.of<AuthenticationController>(context, listen: false);
    bool isLawyer = await authController.isCurrentUserLawyer();
    setState(() {
      _isLawyer = isLawyer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);
    final brightness = MediaQuery.of(context).platformBrightness;
    final userMessageColor =
        brightness == Brightness.dark ? Colors.purple[300] : Colors.blue[600];
    final otherMessageColor =
        brightness == Brightness.dark ? Colors.grey[600] : Colors.grey[300];
    final outlineColor =
        brightness == Brightness.dark ? Colors.white60 : Colors.black54;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (chatController.isLoading) const LinearProgressIndicator(),
            if (_isLawyer)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: DropdownButton<String>(
                  value: _selectedPersona,
                  hint: const Text('Choose a persona'),
                  isExpanded: true, // Makes the dropdown span the whole width
                  items: [
                    'Paralegal',
                    'Researcher',
                    'Contract Analyst',
                    'Co-Counsel',
                  ].map((String persona) {
                    return DropdownMenuItem<String>(
                      value: persona,
                      child: Text(persona),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPersona = newValue;
                    });
                  },
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  bool isSystemMessage = !message.isUser;
                  return Column(
                    children: [
                      if (message.isUser)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: userMessageColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              message.content,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      if (!message.isUser)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              message.content,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      if (isSystemMessage)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Tooltip(
                                message: 'Pass',
                                child: IconButton(
                                  icon: Icon(
                                    _thumbUpClicked
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    size: 20,
                                    color: _thumbUpClicked
                                        ? outlineColor
                                        : outlineColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _thumbUpClicked = !_thumbUpClicked;
                                      _thumbDownClicked = false;
                                    });
                                  },
                                ),
                              ),
                              Tooltip(
                                message: 'Fail',
                                child: IconButton(
                                  icon: Icon(
                                    _thumbDownClicked
                                        ? Icons.thumb_down
                                        : Icons.thumb_down_outlined,
                                    size: 20,
                                    color: _thumbDownClicked
                                        ? outlineColor
                                        : outlineColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _thumbDownClicked = !_thumbDownClicked;
                                      _thumbUpClicked = false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chatController.messageController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Message your legal advisor...',
                        hintStyle: TextStyle(
                          color: brightness == Brightness.dark
                              ? Colors.white60
                              : Colors.black54,
                        ),
                      ),
                      onSubmitted: (value) {
                        chatController.sendMessage(value);
                        chatController.messageController.clear();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      chatController.sendMessage(
                        chatController.messageController.text,
                      );
                      chatController.messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
