import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import '../authentication/authentication_controller.dart';

class Settings extends StatelessWidget {
  Settings({
    super.key,
    required this.settingsController,
  });

  static const routeName = '/settings';

  final SettingsController settingsController;
  final AuthenticationController _authenticationController =
      AuthenticationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>?>(
                future: _authenticationController.getCurrentUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('ERROR: ${snapshot.error}');
                  }
                  final userData = snapshot.data;
                  if (userData == null) {
                    return const Text('No user details found');
                  }
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(
                              '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: Text(userData['phone'] ?? ''),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: Text(_authenticationController
                                    .getCurrentUser()
                                    ?.email ??
                                ''),
                          ),
                          ListTile(
                            leading: const Icon(Icons.home),
                            title: Text(userData['address'] ?? ''),
                          ),
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(userData['country'] ?? ''),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode),
                        title: const Text('Mode'),
                        trailing: DropdownButton<ThemeMode>(
                          value: settingsController.themeMode,
                          onChanged: settingsController.updateThemeMode,
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
