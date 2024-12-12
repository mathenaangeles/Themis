import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:themis/src/components/navbar.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'authentication/login.dart';

import 'package:firebase_auth/firebase_auth.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // Add more locales as needed
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                return AuthenticationWrapper(
                  settingsController: settingsController,
                  routeSettings: routeSettings,
                );
              },
            );
          },
        );
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({
    super.key,
    required this.settingsController,
    required this.routeSettings,
  });

  final SettingsController settingsController;
  final RouteSettings routeSettings;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, show main content with Navbar
          switch (routeSettings.name) {
            case '/settings':
              return Scaffold(
                appBar: AppBar(title: const Text('Settings')),
                drawer: const Navbar(), // Add Navbar for logged-in users
                body: SettingsView(controller: settingsController),
              );
            case '/home':
              return Scaffold(
                appBar: AppBar(title: const Text('Home')),
                drawer: const Navbar(), // Add Navbar for logged-in users
              );
            case '/chat':
              return Scaffold(
                appBar: AppBar(title: const Text('Chat')),
                drawer: const Navbar(), // Add Navbar for logged-in users
              );
            default:
              return Scaffold(
                appBar: AppBar(title: const Text('Home')),
                drawer: const Navbar(), // Add Navbar for logged-in users
              );
          }
        } else {
          // User is not logged in, show login screen
          return const Login();
        }
      },
    );
  }
}
