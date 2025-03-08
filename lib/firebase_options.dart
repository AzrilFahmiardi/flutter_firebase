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
    apiKey: 'AIzaSyAj66gtmoOUKyA2hNSO7SABMurHFuM7TBk',
    appId: '1:389230571789:web:6c58de6187d28962750044',
    messagingSenderId: '389230571789',
    projectId: 'foodwise-9ba0d',
    authDomain: 'foodwise-9ba0d.firebaseapp.com',
    storageBucket: 'foodwise-9ba0d.firebasestorage.app',
    measurementId: 'G-96W3E64TG9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4OaE2KqX7A7-yrC0dZXUNm5R9SlO7M28',
    appId: '1:389230571789:android:95f47bffa1a40d28750044',
    messagingSenderId: '389230571789',
    projectId: 'foodwise-9ba0d',
    storageBucket: 'foodwise-9ba0d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC68aNFZax9eXe16tziac6Fy996cSfay_0',
    appId: '1:389230571789:ios:27ccdf9f4320137d750044',
    messagingSenderId: '389230571789',
    projectId: 'foodwise-9ba0d',
    storageBucket: 'foodwise-9ba0d.firebasestorage.app',
    androidClientId: '389230571789-7t5cksddrt5a23jvqah1n5q1afi5mrlf.apps.googleusercontent.com',
    iosClientId: '389230571789-kd8n70np0ua2512k1f8pg39daiaj1g6v.apps.googleusercontent.com',
    iosBundleId: 'com.example.tesFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC68aNFZax9eXe16tziac6Fy996cSfay_0',
    appId: '1:389230571789:ios:27ccdf9f4320137d750044',
    messagingSenderId: '389230571789',
    projectId: 'foodwise-9ba0d',
    storageBucket: 'foodwise-9ba0d.firebasestorage.app',
    androidClientId: '389230571789-7t5cksddrt5a23jvqah1n5q1afi5mrlf.apps.googleusercontent.com',
    iosClientId: '389230571789-kd8n70np0ua2512k1f8pg39daiaj1g6v.apps.googleusercontent.com',
    iosBundleId: 'com.example.tesFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAj66gtmoOUKyA2hNSO7SABMurHFuM7TBk',
    appId: '1:389230571789:web:bec3db96c2e3c8f8750044',
    messagingSenderId: '389230571789',
    projectId: 'foodwise-9ba0d',
    authDomain: 'foodwise-9ba0d.firebaseapp.com',
    storageBucket: 'foodwise-9ba0d.firebasestorage.app',
    measurementId: 'G-EPGRDV7H8H',
  );

}