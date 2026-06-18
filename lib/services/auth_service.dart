import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _userModel = null;
    } else {
      // Verificar y actualizar membresía vencida antes de cargar el perfil
      await DatabaseService().checkAndUpdateExpiredSubscription(user.uid);
      _userModel = await DatabaseService().getUser(user.uid);

      // Si es admin, asegurarse que tenga pendingApproval = false
      if (_userModel?.role == 'admin' && (_userModel?.pendingApproval == true)) {
        await DatabaseService().updateUserRole(user.uid, 'admin');
        await _db.collection('user').doc(user.uid).update({
          'pendingApproval': false,
          'isSubscribed': true,
        });
        _userModel = await DatabaseService().getUser(user.uid);
      }
    }
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password, String name, {String zodiacSign = ''}) async {
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
          pendingApproval: true,
        );
        await DatabaseService().saveUser(newUser);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Crear usuario desde el panel admin sin cerrar sesión del admin
  Future<String?> createUserAsAdmin(String email, String password, String name, String role) async {
    // Guardamos las credenciales del admin actual
    final adminUser = _auth.currentUser;
    if (adminUser == null) return 'No hay sesión de admin activa';

    try {
      // Creamos el nuevo usuario
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
        // Cerramos la sesión del nuevo usuario y volvemos a iniciar con el admin
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
      _userModel = await DatabaseService().getUser(user.uid);
    }
    notifyListeners();
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return 'Inicio de sesión cancelado';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        UserModel? existingUser = await DatabaseService().getUser(user.uid);

        if (existingUser == null) {
          UserModel newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'Usuario de Google',
            email: user.email ?? '',
            role: 'user',
            isSubscribed: false,
            zodiacSign: '',
            pendingApproval: true,
          );
          await DatabaseService().saveUser(newUser);
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
