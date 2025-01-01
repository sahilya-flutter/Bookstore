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
    apiKey: 'AIzaSyCUMQ9GAPHU6cI3ddoq2aohZxIOXwpELVA',
    appId: '1:138908168307:web:7c156e6e765a78bc443a06',
    messagingSenderId: '138908168307',
    projectId: 'bookstore-fd6ff',
    authDomain: 'bookstore-fd6ff.firebaseapp.com',
    storageBucket: 'bookstore-fd6ff.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAiqgUCC1SgKR7TXxLHbQoadkD8jVQbdi0',
    appId: '1:138908168307:android:b12233d86afb7b30443a06',
    messagingSenderId: '138908168307',
    projectId: 'bookstore-fd6ff',
    storageBucket: 'bookstore-fd6ff.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvpt_nvUgkWGKvPKM9_ucio8OuCw0a6n0',
    appId: '1:138908168307:ios:5a805ca33ac1945b443a06',
    messagingSenderId: '138908168307',
    projectId: 'bookstore-fd6ff',
    storageBucket: 'bookstore-fd6ff.firebasestorage.app',
    iosBundleId: 'com.example.bookStore',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCvpt_nvUgkWGKvPKM9_ucio8OuCw0a6n0',
    appId: '1:138908168307:ios:5a805ca33ac1945b443a06',
    messagingSenderId: '138908168307',
    projectId: 'bookstore-fd6ff',
    storageBucket: 'bookstore-fd6ff.firebasestorage.app',
    iosBundleId: 'com.example.bookStore',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCUMQ9GAPHU6cI3ddoq2aohZxIOXwpELVA',
    appId: '1:138908168307:web:f0da21a4374e52b0443a06',
    messagingSenderId: '138908168307',
    projectId: 'bookstore-fd6ff',
    authDomain: 'bookstore-fd6ff.firebaseapp.com',
    storageBucket: 'bookstore-fd6ff.firebasestorage.app',
  );
}
