import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/occult_logo.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAndNavigate();
    });
  }

  Future<void> _initAndNavigate() async {
    // Esperamos primero a que se muestre el logo y que Firebase Web restaure IndexedDB en móvil
    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted || _navigated) return;

    Widget targetScreen = const LoginScreen();

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        try {
          currentUser = await FirebaseAuth.instance
              .authStateChanges()
              .first
              .timeout(const Duration(milliseconds: 400));
        } catch (_) {}
      }

      if (currentUser == null) {
        targetScreen = const LoginScreen();
      } else {
        targetScreen = const HomeScreen();

        DatabaseService()
            .checkAndUpdateExpiredSubscription(currentUser.uid)
            .catchError((e) {
          debugPrint("Error al sincronizar suscripción en splash: $e");
        });

        if (mounted) {
          final authService = Provider.of<AuthService>(context, listen: false);
          authService.reloadCurrentUser().catchError((e) {
            debugPrint("Error al recargar usuario en splash: $e");
          });
        }
      }
    } catch (e) {
      debugPrint("Error en splash checkAuth: $e");
      targetScreen = const LoginScreen();
    }

    if (!mounted || _navigated) return;
    _navigated = true;
    _ctrl.stop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF220000), Color(0xFF080808)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const OccultLogo(size: 110),
              const SizedBox(height: 24),
              Text(
                'LA FUERZA',
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'DEL OCULTISMO',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFD4AF37),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
