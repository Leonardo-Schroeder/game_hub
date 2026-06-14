// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Dados configurados corretamente para a Web em formato Dart
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAEs3gWcF9zzS6nu9PVDLRieQVotTDuk7w",
    authDomain: "gamehub-cda37.firebaseapp.com",
    projectId: "gamehub-cda37",
    storageBucket: "gamehub-cda37.firebasestorage.app",
    messagingSenderId: "531646344106",
    appId: "1:531646344106:web:d9ed5551021542a36f99d3",
    measurementId: "G-CRMQZGCW8P",
  );

  // Dados configurados corretamente para o Android em formato Dart
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAEs3gWcF9zzS6nu9PVDLRieQVotTDuk7w",
    authDomain: "gamehub-cda37.firebaseapp.com",
    projectId: "gamehub-cda37",
    storageBucket: "gamehub-cda37.firebasestorage.app",
    messagingSenderId: "531646344106",
    appId: "1:531646344106:web:d9ed5551021542a36f99d3",
    measurementId: "G-CRMQZGCW8P",
  );
}