import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _userModel;

  UserModel? get userModel => _userModel;
  User? get currentUser => _auth.currentUser;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    if (kIsWeb) {
      _checkWebRedirectResult();
    }
  }

  Future<void> _checkWebRedirectResult() async {
    try {
      final UserCredential redirectResult = await _auth.getRedirectResult();
      if (redirectResult.user != null) {
        await _ensureUserModelForGoogleUser(redirectResult.user!);
      }
    } catch (e) {
      debugPrint('Aviso getRedirectResult en AuthService: $e');
    }
  }

  Future<void> _ensureUserModelForGoogleUser(User user) async {
    final UserModel fallbackUser = UserModel(
      uid: user.uid,
      name: (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : 'Usuario de Google',
      email: user.email ?? '',
      role: 'user',
      isSubscribed: false,
      zodiacSign: '',
      pendingApproval: false,
    );

    // Asignar modelo inmediato para no bloquear la navegación en móvil
    _userModel ??= fallbackUser;
    notifyListeners();

    try {
      final UserModel? existingUser = await DatabaseService()
          .getUser(user.uid)
          .timeout(const Duration(seconds: 4));

      if (existingUser == null) {
        await DatabaseService()
            .saveUser(fallbackUser)
            .timeout(const Duration(seconds: 4));
        _userModel = fallbackUser;
      } else {
        _userModel = existingUser;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Aviso sincronizando perfil Google en Firestore: $e');
      DatabaseService().getUser(user.uid).then((existing) {
        if (existing == null) {
          DatabaseService().saveUser(fallbackUser).catchError((_) {});
        } else {
          _userModel = existing;
          notifyListeners();
        }
      }).catchError((_) {});
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _userModel = null;
    } else {
      if (_userModel == null || _userModel!.uid != user.uid) {
        try {
          _userModel = await DatabaseService()
              .getUser(user.uid)
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('Error cargando usuario en _onAuthStateChanged: $e');
        }
        if (_userModel == null) {
          await _ensureUserModelForGoogleUser(user);
        }
      }

      // Si es admin, asegurarse que tenga pendingApproval = false
      if (_userModel?.role == 'admin' && (_userModel?.pendingApproval == true)) {
        try {
          await DatabaseService().updateUserRole(user.uid, 'admin');
          await _db.collection('user').doc(user.uid).update({
            'pendingApproval': false,
            'isSubscribed': true,
          });
          _userModel = await DatabaseService().getUser(user.uid);
        } catch (e) {
          debugPrint('Error actualizando estado admin: $e');
        }
      }
    }
    notifyListeners();
  }

  String _traducirErrorFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'El correo o la contraseña ingresados son incorrectos.';
      case 'invalid-email':
        return 'El correo electrónico ingresado no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido desactivada. Contacta al administrador.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta registrada con este correo electrónico.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Por favor, espera un momento antes de volver a intentar.';
      case 'network-request-failed':
        return 'Error de conexión. Por favor verifica tu acceso a internet.';
      case 'operation-not-allowed':
        return 'Esta opción de inicio de sesión no está disponible actualmente.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo asociada a otro método de acceso.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Inicio de sesión con Google cancelado.';
      case 'popup-blocked':
        return 'Tu navegador bloqueó la ventana emergente. Permite ventanas emergentes e intenta de nuevo.';
      case 'web-storage-unsupported':
        return 'Tu navegador bloqueó el almacenamiento de sesión. Intenta en Chrome o Safari sin modo incógnito.';
      case 'unauthorized-domain':
        return 'Dominio no autorizado para inicio con Google.';
      default:
        if (e.message != null && e.message!.toLowerCase().contains('credential')) {
          return 'El correo o la contraseña ingresados son incorrectos.';
        }
        return e.message ?? 'Ocurrió un error al intentar autenticarte.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        _userModel = await DatabaseService().getUser(result.user!.uid);
        notifyListeners();
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirErrorFirebase(e);
    } catch (e) {
      return 'Error al iniciar sesión: ${e.toString()}';
    }
  }

  Future<String?> signUp(
    String email,
    String password,
    String name, {
    String zodiacSign = '',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: 'user',
          isSubscribed: false,
          zodiacSign: zodiacSign,
          pendingApproval: false, // Plan gratuito: acceso directo al app
        );
        await DatabaseService().saveUser(newUser);
        _userModel = newUser;
        notifyListeners();
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirErrorFirebase(e);
    } catch (e) {
      return 'Error al registrarte: ${e.toString()}';
    }
  }

  // Crear usuario desde el panel admin sin cerrar sesión del admin
  Future<String?> createUserAsAdmin(
    String email,
    String password,
    String name,
    String role,
  ) async {
    final adminUser = _auth.currentUser;
    if (adminUser == null) return 'No hay sesión de admin activa';

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? newUser = result.user;

      if (newUser != null) {
        UserModel userModel = UserModel(
          uid: newUser.uid,
          name: name,
          email: email,
          role: role,
        );
        await DatabaseService().saveUser(userModel);
        await _auth.signOut();
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteUser(String uid) async {
    try {
      await DatabaseService().deleteUserData(uid);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      _userModel = null;
    } else {
      try {
        _userModel = await DatabaseService()
            .getUser(user.uid)
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('Error en reloadCurrentUser: $e');
      }
      if (_userModel == null) {
        await _ensureUserModelForGoogleUser(user);
      }
    }
    notifyListeners();
  }

  Future<String?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        final bool isMobileWeb = defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;

        if (isMobileWeb) {
          // En navegadores móviles (Chrome/Safari móvil), signInWithRedirect es el método
          // estándar recomendado por Firebase para evitar bloqueos de popups y desvinculación de pestañas.
          await _auth.signInWithRedirect(googleProvider);
          return null;
        } else {
          // En computadores (Chrome, Edge, Firefox, etc.) signInWithPopup funciona limpiamente
          // sin recargar la página.
          final UserCredential result =
              await _auth.signInWithPopup(googleProvider);
          final User? user = result.user ?? _auth.currentUser;

          if (user != null) {
            await _ensureUserModelForGoogleUser(user);
            return null;
          }
          return null;
        }
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) {
          return 'Inicio de sesión cancelado';
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential result =
            await _auth.signInWithCredential(credential);
        final User? user = result.user ?? _auth.currentUser;

        if (user != null) {
          await _ensureUserModelForGoogleUser(user);
        }
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (_auth.currentUser != null) {
        await _ensureUserModelForGoogleUser(_auth.currentUser!);
        return null;
      }
      return _traducirErrorFirebase(e);
    } catch (e) {
      if (_auth.currentUser != null) {
        await _ensureUserModelForGoogleUser(_auth.currentUser!);
        return null;
      }
      return 'Error con Google: ${e.toString()}';
    }
  }
}
