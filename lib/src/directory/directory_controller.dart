import 'package:flutter/material.dart';
import 'directory_service.dart';

class DirectoryController extends ChangeNotifier {
  final DirectoryService _directoryService = DirectoryService();
  List<Map<String, dynamic>> _lawyers = [];
  List<Map<String, dynamic>> _filteredLawyers = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get lawyers => _lawyers;
  List<Map<String, dynamic>> get filteredLawyers => _filteredLawyers;
  bool get isLoading => _isLoading;

  Future<void> fetchLawyers() async {
    try {
      _lawyers = await _directoryService.getLawyers();
      _filteredLawyers = _lawyers;
    } catch (e) {
      _lawyers = [];
      _filteredLawyers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterLawyers(String query, Set<String> selectedTags) {
    _filteredLawyers = _lawyers.where((lawyer) {
      final matchesName = query.isEmpty ||
          (lawyer['first_name'] + ' ' + lawyer['last_name'])
              .toLowerCase()
              .contains(query.toLowerCase());
      final matchesTags = selectedTags.isEmpty ||
          (lawyer['tags'] as List<dynamic>).any(selectedTags.contains);

      return matchesName && matchesTags;
    }).toList();
    notifyListeners();
  }
}
