import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
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
    apiKey: 'AIzaSyBBRZc7GpDRD6eselB1-_bec2kQltOzDZs',
    appId: '1:154433564164:android:cf1c876d66b3b60073cf51',
    messagingSenderId: '843986821557',
    projectId: 'libraryapp-27e83',
    authDomain: 'libraryapp-27e83.firebaseapp.com',
    storageBucket: 'libraryapp-27e83.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBRZc7GpDRD6eselB1-_bec2kQltOzDZs',
    appId: '1:154433564164:android:cf1c876d66b3b60073cf51',
    messagingSenderId: '843986821557',
    projectId: 'libraryapp-27e83',
    storageBucket: 'libraryapp-27e83.appspot.com',
  );
}
