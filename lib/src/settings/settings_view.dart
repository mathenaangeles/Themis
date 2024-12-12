import 'package:flutter/material.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await controller.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Name: ${controller.userData?['first_name'] ?? ''} ${controller.userData?['last_name'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Email: ${controller.userData?['email'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Address: ${controller.userData?['address'] ?? ''}'),
                  const SizedBox(height: 8),
                  Text('Country: ${controller.userData?['country'] ?? ''}'),
                  const SizedBox(height: 24),
                  DropdownButton<ThemeMode>(
                    value: controller.themeMode,
                    onChanged: controller.updateThemeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Theme'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
