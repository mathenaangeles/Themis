import 'package:flutter/material.dart';
import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  ThemeMode _themeMode = ThemeMode.system;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _themeMode = await _settingsService.themeMode();
      _userData = await _settingsService.getUserData();
    } catch (e) {
      _userData = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    await _settingsService.updateUserData(updatedData);
    _userData = {...?_userData, ...updatedData};
    notifyListeners();
  }

  Future<void> logout() async {
    await _settingsService.logoutUser();
  }
}
