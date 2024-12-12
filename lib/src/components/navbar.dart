import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Navbar extends StatelessWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Guest'),
            accountEmail: Text(user?.email ?? 'Not logged in'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(user?.displayName?.substring(0, 1) ?? 'G'),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            title: const Text('Chat'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/chat');
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
          if (user != null)
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
        ],
      ),
    );
  }
}
