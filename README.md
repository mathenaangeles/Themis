# Themis

Themis is an AI-powered platform that provides access to legal counsel and automates routine tasks within the justice system. It empowers vulnerable populations to discover and exercise their rights responsibly.

## Getting Started
1. Run `flutter pub get` to install all dependencies.
2. [OPTIONAL] To ensure that the Firebase configuration is up-to-date, `dart pub global run flutterfire_cli:flutterfire configure`.
3. Run `flutter run -d chrome --web-renderer=html`.

## Deployment
1. Run `flutter build web --release` to build the Flutter web application.
2. RUn `firebase deploy` to re-deploy it to Firebase.
3. [OPTIONAL] To redeploy all your function, run `firebase deploy --only functions` or `firebase deploy --only functions:<INSERT FUNCTION NAME HERE>` to deploy one specific function.


