import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String _baseUrl =
      'https://legaladvisorfunction-sgpv2va7uq-uc.a.run.app/';
  Future<String> getLegalAdvice(String query) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );
      if (response.statusCode == 200) {
        return response.body.trim();
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (error) {
      throw Exception('Error calling cloud function: $error');
    }
  }
}
