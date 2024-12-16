import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'package:themis/src/chat/message.dart';

class ChatController with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final TextEditingController messageController = TextEditingController();

  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  void sendMessage(String userQuery) async {
    if (userQuery.isEmpty) return;

    _messages.add(Message(content: userQuery, isUser: true));
    messageController.clear();
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatService.getLegalAdvice(userQuery);
      _messages.add(Message(content: response, isUser: false));
    } catch (error) {
      print(error);
      _messages.add(
        Message(
          content: 'An error occurred while fetching advice. Please try again.',
          isUser: false,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
