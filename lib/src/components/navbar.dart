import 'package:flutter/material.dart';

import 'package:themis/src/authentication/authentication_controller.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  NavbarState createState() => NavbarState();
}

class NavbarState extends State<Navbar> {
  final AuthenticationController _authenticationController =
      AuthenticationController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple[600],
            ),
            accountName: FutureBuilder<Map<String, dynamic>?>(
              future: _authenticationController.getCurrentUserDetails(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Text('');
                }
                if (userSnapshot.hasError) {
                  return Text('ERROR: ${userSnapshot.error}');
                }
                final userData = userSnapshot.data;
                return Text(
                  userData != null
                      ? userData['first_name'] + ' ' + userData['last_name'] ??
                          'Guest'
                      : 'Guest',
                );
              },
            ),
            accountEmail: Text(
              _authenticationController.getCurrentUser()?.email ?? '',
            ),
            currentAccountPicture: FutureBuilder<Map<String, dynamic>?>(
              future: _authenticationController.getCurrentUserDetails(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (userSnapshot.hasError) {
                  return const Icon(Icons.account_circle);
                }
                final userData = userSnapshot.data;
                String firstName =
                    userData != null ? userData['first_name'] ?? 'G' : 'G';

                return CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    firstName.substring(0, 1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[300],
                    ),
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Chat'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/chat');
            },
          ),
          ListTile(
            title: const Text('Directory'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/directory');
            },
          ),
          ListTile(
            title: const Text('Documents'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/documents');
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              await _authenticationController.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          )
        ],
      ),
    );
  }
}
