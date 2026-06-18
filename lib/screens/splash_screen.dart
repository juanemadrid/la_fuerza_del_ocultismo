import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'membresia_vencida_screen.dart';
import 'pending_approval_screen.dart';
import 'select_plan_screen.dart';
import 'admin/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navega de inmediato sin animaciones
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _goTo(const LoginScreen());
      return;
    }

    await DatabaseService().checkAndUpdateExpiredSubscription(currentUser.uid);

    if (!mounted) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.reloadCurrentUser();

    if (!mounted) return;
    final user = authService.userModel;

    if (user == null) {
      _goTo(const LoginScreen());
      return;
    }

    if (user.role == 'admin') {
      _goTo(const AdminDashboard());
      return;
    }

    if (user.pendingApproval &&
        user.subscriptionExpiry == null &&
        user.pendingPlanId == null) {
      _goTo(const SelectPlanScreen());
      return;
    }

    if (user.pendingApproval && user.subscriptionExpiry == null) {
      _goTo(const PendingApprovalScreen());
      return;
    }

    user.isMembershipActive
        ? _goTo(const HomeScreen())
        : _goTo(const MembresiaVencidaScreen());
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla negra mientras verifica auth — sin animaciones, sin texto
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(),
    );
  }
}
