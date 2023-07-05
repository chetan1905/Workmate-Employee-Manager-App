// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAT6hZyDQ5YCoBzoaMSpKZmDIvInzgb7KQ',
    appId: '1:680005967987:web:bbd1f49bdaddd954044a16',
    messagingSenderId: '680005967987',
    projectId: 'attendancemanager-91063',
    authDomain: 'attendancemanager-91063.firebaseapp.com',
    storageBucket: 'attendancemanager-91063.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCD4yrSSq2hmfV4kbTKsRWBbUTM6Fy0duQ',
    appId: '1:680005967987:android:a5a566080312b48b034a06',
    messagingSenderId: '680005967987',
    projectId: 'attendancemanager-91063',
    storageBucket: 'attendancemanager-91063.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZNeG4PvLfBxBK1oChyolLGuTkypI-OQk',
    appId: '1:680005966987:ios:1e43077fa1184278044a06',
    messagingSenderId: '680005967987',
    projectId: 'attendancemanager-91063',
    storageBucket: 'attendancemanager-91063.appspot.com',
    iosClientId: '680005967987-fr9lno9nghdo5bb4c3iiniqklhnlpdq0.apps.googleusercontent.com',
    iosBundleId: 'com.example.newAttendanceManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBZNeG8PvLfBxBK1oChyolLGuTkypI-OQk',
    appId: '1:680005967988:ios:1e43077fa1184278044a06',
    messagingSenderId: '680005967987',
    projectId: 'attendancemanager-91063',
    storageBucket: 'attendancemanager-91063.appspot.com',
    iosClientId: '680005967987-fr9lno9nghdo5bb4c3iiniqklhnlpdq0.apps.googleusercontent.com',
    iosBundleId: 'com.example.newAttendanceManager',
  );
}
