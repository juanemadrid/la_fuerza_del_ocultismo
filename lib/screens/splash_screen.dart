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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _glowAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1)),
    );

    _controller.forward();

    // Navegar después de la animación
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _goTo(const LoginScreen());
      return;
    }

    // Verificar membresía vencida
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

    // Admin siempre entra sin restricciones — directo al panel
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

    // Pendiente de aprobación
    if (user.pendingApproval && user.subscriptionExpiry == null) {
      _goTo(const PendingApprovalScreen());
      return;
    }

    // Membresía activa
    if (user.isMembershipActive) {
      _goTo(const HomeScreen());
    } else {
      _goTo(const MembresiaVencidaScreen());
    }
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1A0000), Color(0xFF0D0D0D)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo con glow
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB71C1C)
                                  .withOpacity(0.3 * _glowAnim.value),
                              blurRadius: 40 * _glowAnim.value,
                              spreadRadius: 10 * _glowAnim.value,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _TrianglePainter(
                            glowIntensity: _glowAnim.value,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Nombre de la app
                      Opacity(
                        opacity: _glowAnim.value,
                        child: const Text(
                          'LA FUERZA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Opacity(
                        opacity: _glowAnim.value,
                        child: const Text(
                          'DEL OCULTISMO',
                          style: TextStyle(
                            color: Color(0xFFB71C1C),
                            fontSize: 14,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),

                      // Indicador de carga
                      Opacity(
                        opacity: _glowAnim.value,
                        child: SizedBox(
                          width: 40,
                          height: 2,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFB71C1C),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Dibuja el triángulo místico con ojo
class _TrianglePainter extends CustomPainter {
  final double glowIntensity;

  _TrianglePainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.45;

    final paintOuter = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = MaskFilter.blur(
          BlurStyle.outer, 8 * glowIntensity);

    final paintInner = Paint()
      ..color = const Color(0xFFB71C1C).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintFill = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.fill;

    final paintDark = Paint()
      ..color = const Color(0xFF0D0D0D)
      ..style = PaintingStyle.fill;

    // Triángulo exterior
    final outerPath = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r * 0.866, cy + r * 0.5)
      ..lineTo(cx - r * 0.866, cy + r * 0.5)
      ..close();
    canvas.drawPath(outerPath, paintOuter);

    // Triángulo interior
    final ri = r * 0.6;
    final innerPath = Path()
      ..moveTo(cx, cy - ri)
      ..lineTo(cx + ri * 0.866, cy + ri * 0.5)
      ..lineTo(cx - ri * 0.866, cy + ri * 0.5)
      ..close();
    canvas.drawPath(innerPath, paintInner);

    // Ojo central
    final eyeR = r * 0.18;
    canvas.drawCircle(Offset(cx, cy), eyeR, paintFill);
    canvas.drawCircle(Offset(cx, cy), eyeR * 0.5, paintDark);

    // Líneas horizontales del ojo
    final linePaint = Paint()
      ..color = const Color(0xFFB71C1C).withOpacity(0.7)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(cx - ri * 0.7, cy),
      Offset(cx - eyeR, cy),
      linePaint,
    );
    canvas.drawLine(
      Offset(cx + eyeR, cy),
      Offset(cx + ri * 0.7, cy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.glowIntensity != glowIntensity;
}
