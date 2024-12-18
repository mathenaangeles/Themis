// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBv1DVamsh91g_a9qD0OUP1fFJ-FAEbe8Q',
    appId: '1:798311939348:web:bb674a235faf393e1b9601',
    messagingSenderId: '798311939348',
    projectId: 'themis-9e1e1',
    authDomain: 'themis-9e1e1.firebaseapp.com',
    storageBucket: 'themis-9e1e1.firebasestorage.app',
    measurementId: 'G-6X26B21NF1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCKeu4b1ZOtTt1twr9lYiAYJvVoXuXe1Yo',
    appId: '1:798311939348:android:0e27e3c589578a561b9601',
    messagingSenderId: '798311939348',
    projectId: 'themis-9e1e1',
    storageBucket: 'themis-9e1e1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBpYwZiUXoKPgXiSGGYI1YL4ksAAUvkpCQ',
    appId: '1:798311939348:ios:ede04a0b5fde1c221b9601',
    messagingSenderId: '798311939348',
    projectId: 'themis-9e1e1',
    storageBucket: 'themis-9e1e1.firebasestorage.app',
    iosBundleId: 'com.example.themis',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBpYwZiUXoKPgXiSGGYI1YL4ksAAUvkpCQ',
    appId: '1:798311939348:ios:ede04a0b5fde1c221b9601',
    messagingSenderId: '798311939348',
    projectId: 'themis-9e1e1',
    storageBucket: 'themis-9e1e1.firebasestorage.app',
    iosBundleId: 'com.example.themis',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBv1DVamsh91g_a9qD0OUP1fFJ-FAEbe8Q',
    appId: '1:798311939348:web:2014ecfa4a3438271b9601',
    messagingSenderId: '798311939348',
    projectId: 'themis-9e1e1',
    authDomain: 'themis-9e1e1.firebaseapp.com',
    storageBucket: 'themis-9e1e1.firebasestorage.app',
    measurementId: 'G-MNPHCLJ5VY',
  );

}