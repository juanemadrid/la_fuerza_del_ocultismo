import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();

  // DIAGNÓSTICO TEMPORAL: en vez de pintar negro, muestra el error en pantalla
  // para poder ver qué falla en iPhone. Quitar cuando se resuelva.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('DIAG_ERROR ErrorWidget: ${details.exceptionAsString()}');
    return ColoredBox(
      color: const Color(0xFF080808),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Error: ${details.exceptionAsString()}',
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
        ),
      ),
    );
  };
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('DIAG_ERROR Flutter: ${details.exceptionAsString()}\n'
        '${details.stack.toString().split('\n').take(6).join('\n')}');
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('DIAG_ERROR Async: $error\n'
        '${stack.toString().split('\n').take(6).join('\n')}');
    return true;
  };

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    logger.e("Firebase initialization failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'La Fuerza Del Ocultismo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
