import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:themis/src/authentication/authentication_controller.dart';
import 'package:themis/src/chat/advisor.dart';

import 'package:themis/src/components/navbar.dart';
import 'package:themis/src/directory/directory_controller.dart';
import 'package:themis/src/documents/documents.dart';
import 'package:themis/src/documents/documents_controller.dart';
import 'package:themis/src/documents/forms/demand_letter.dart';
import 'settings/settings.dart';
import 'directory/directory.dart';
import 'authentication/login.dart';
import 'settings/settings_controller.dart';
import 'chat/chat_controller.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => DirectoryController()),
        ChangeNotifierProvider(create: (_) => AuthenticationController()),
        ChangeNotifierProvider(create: (_) => DocumentsController()),
      ],
      child: ListenableBuilder(
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
              Locale('en', ''),
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
      ),
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
          switch (routeSettings.name) {
            case '/settings':
              return Scaffold(
                appBar: AppBar(title: const Text('Settings')),
                drawer: const Navbar(),
                body: Settings(settingsController: settingsController),
              );
            case '/chat':
              return Scaffold(
                appBar: AppBar(title: const Text('Chat')),
                drawer: const Navbar(),
                body: Advisor(),
              );
            case '/directory':
              return Scaffold(
                appBar: AppBar(title: const Text('Directory')),
                drawer: const Navbar(),
                body: Directory(),
              );
            case '/documents':
              return Scaffold(
                appBar: AppBar(title: const Text('Documents')),
                drawer: const Navbar(),
                body: Documents(),
              );
            case '/demand_letter':
              return Scaffold(
                appBar: AppBar(title: const Text('Demand Letter')),
                drawer: const Navbar(),
                body: DemandLetter(),
              );
            default:
              return Scaffold(
                appBar: AppBar(title: const Text('Chat')),
                drawer: const Navbar(),
                body: Advisor(),
              );
          }
        } else {
          return const Login();
        }
      },
    );
  }
}
