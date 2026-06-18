// Archivo generado para configuración de Firebase por plataforma.
// Para obtener los valores web, ve a:
// Firebase Console > la-fuerza-del-ocultismo > Configuración > Apps > Web
// y copia el firebaseConfig.

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
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // =====================================================
  // CONFIGURACIÓN WEB
  // Para obtener estos valores:
  // 1. Ve a https://console.firebase.google.com/project/la-fuerza-del-ocultismo/settings/general
  // 2. Busca "Tus apps" y haz clic en el ícono web (</>)
  // 3. Si no existe app web, haz clic en "Agregar app" > Web
  // 4. Copia los valores de firebaseConfig
  // =====================================================
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_E1e7vC8tWoQJk0GquRa6CMA-qkgMq_k',
    appId: '1:266342039579:web:e38fae2210cd2c9f6bf8be',
    messagingSenderId: '266342039579',
    projectId: 'fuerzadelocultismo',
    authDomain: 'fuerzadelocultismo.firebaseapp.com',
    storageBucket: 'fuerzadelocultismo.firebasestorage.app',
    measurementId: 'G-Q0BPX2N09',
  );

  // =====================================================
  // CONFIGURACIÓN ANDROID (valores originales)
  // =====================================================
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDp5_YiyYTv-MpcGONfoTHJlAEYkY_6QUk',
    appId: '1:135659875300:android:0cba5a69c64d30b25775f1',
    messagingSenderId: '135659875300',
    projectId: 'la-fuerza-del-ocultismo',
    storageBucket: 'la-fuerza-del-ocultismo.firebasestorage.app',
  );
}
