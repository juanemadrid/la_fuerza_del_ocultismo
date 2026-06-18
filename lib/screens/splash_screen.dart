import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
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
    with TickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _masterCtrl;   // Orquesta todo (4s)
  late AnimationController _rotateCtrl;   // Giro continuo de anillos
  late AnimationController _pulseCtrl;    // Pulso del glow central
  late AnimationController _particleCtrl; // Partículas de fuego

  // Animaciones maestras
  late Animation<double> _bgReveal;
  late Animation<double> _ringReveal;
  late Animation<double> _symbolReveal;
  late Animation<double> _textReveal;
  late Animation<double> _progressReveal;
  late Animation<double> _progressValue;

  // Partículas
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _generateParticles();

    // ── Master (4 segundos, secuencia orquestada) ──
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _bgReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.0, 0.15, curve: Curves.easeIn)),
    );
    _ringReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.12, 0.45, curve: Curves.easeOutCubic)),
    );
    _symbolReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.30, 0.65, curve: Curves.easeOutBack)),
    );
    _textReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.55, 0.80, curve: Curves.easeOut)),
    );
    _progressReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.72, 0.85, curve: Curves.easeOut)),
    );
    _progressValue = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.78, 1.0, curve: Curves.easeInOut)),
    );

    // ── Rotación continua de anillos ──
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // ── Pulso de glow ──
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // ── Partículas ──
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    )..addListener(() {
        setState(() {
          for (final p in _particles) {
            p.update();
          }
        });
      })
      ..repeat();

    _masterCtrl.forward();

    // Navegar al terminar
    Future.delayed(const Duration(milliseconds: 4400), _navigate);
  }

  void _generateParticles() {
    for (int i = 0; i < 28; i++) {
      _particles.add(_Particle(_rng));
    }
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
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _rotateCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_masterCtrl, _rotateCtrl, _pulseCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              // ── Fondo: gradiente radial rojo que se expande ──
              Opacity(
                opacity: _bgReveal.value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.4,
                      colors: [
                        const Color(0xFF1A0000).withOpacity(0.95),
                        const Color(0xFF0A0000).withOpacity(0.98),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Partículas de fuego ──
              if (_ringReveal.value > 0.3)
                Opacity(
                  opacity: ((_ringReveal.value - 0.3) / 0.7).clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: Size(size.width, size.height),
                    painter: _ParticlePainter(_particles, size),
                  ),
                ),

              // ── Centro: anillos + símbolo ──
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anillo exterior girando lento
                    if (_ringReveal.value > 0)
                      Opacity(
                        opacity: _ringReveal.value,
                        child: Transform.rotate(
                          angle: _rotateCtrl.value * 2 * pi,
                          child: CustomPaint(
                            size: const Size(260, 260),
                            painter: _RingPainter(
                              color: const Color(0xFFB71C1C),
                              strokeWidth: 1.2,
                              dashes: 24,
                              glowIntensity: _pulseCtrl.value,
                            ),
                          ),
                        ),
                      ),

                    // Anillo medio girando al revés
                    if (_ringReveal.value > 0.2)
                      Opacity(
                        opacity: ((_ringReveal.value - 0.2) / 0.8).clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: -_rotateCtrl.value * 2 * pi * 1.6,
                          child: CustomPaint(
                            size: const Size(210, 210),
                            painter: _RingPainter(
                              color: const Color(0xFFEF233C),
                              strokeWidth: 1.0,
                              dashes: 16,
                              glowIntensity: _pulseCtrl.value,
                              runeMarks: true,
                            ),
                          ),
                        ),
                      ),

                    // Anillo interior girando
                    if (_ringReveal.value > 0.4)
                      Opacity(
                        opacity: ((_ringReveal.value - 0.4) / 0.6).clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: _rotateCtrl.value * 2 * pi * 2.2,
                          child: CustomPaint(
                            size: const Size(158, 158),
                            painter: _RingPainter(
                              color: const Color(0xFF7A0000),
                              strokeWidth: 0.8,
                              dashes: 8,
                              glowIntensity: _pulseCtrl.value,
                            ),
                          ),
                        ),
                      ),

                    // Glow central pulsante
                    if (_symbolReveal.value > 0)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB71C1C).withOpacity(
                                0.5 * _symbolReveal.value * (0.6 + 0.4 * _pulseCtrl.value),
                              ),
                              blurRadius: 60 * _symbolReveal.value,
                              spreadRadius: 20 * _symbolReveal.value * _pulseCtrl.value,
                            ),
                          ],
                        ),
                      ),

                    // Pentagrama + símbolo central
                    if (_symbolReveal.value > 0)
                      Transform.scale(
                        scale: _symbolReveal.value,
                        child: Opacity(
                          opacity: _symbolReveal.value,
                          child: CustomPaint(
                            size: const Size(140, 140),
                            painter: _PentagramPainter(
                              glowIntensity: _pulseCtrl.value,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Texto del título ──
              Positioned(
                bottom: size.height * 0.28,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _textReveal.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _textReveal.value)),
                    child: Column(
                      children: [
                        // Línea decorativa izquierda
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 1,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Color(0xFFB71C1C)],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'LA FUERZA',
                              style: GoogleFonts.cinzel(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 9,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              width: 40,
                              height: 1,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFB71C1C), Colors.transparent],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'DEL OCULTISMO',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFEF233C),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 7,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '✦  PORTAL SAGRADO  ✦',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFD4AF37).withOpacity(0.7),
                            fontSize: 9,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Barra de progreso ──
              Positioned(
                bottom: size.height * 0.10,
                left: size.width * 0.25,
                right: size.width * 0.25,
                child: Opacity(
                  opacity: _progressReveal.value,
                  child: Column(
                    children: [
                      // Barra
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressValue.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7A0000), Color(0xFFEF233C)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF233C).withOpacity(0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Abriendo el portal...',
                        style: GoogleFonts.inter(
                          color: Colors.white24,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PARTÍCULA DE FUEGO
// ─────────────────────────────────────────────
class _Particle {
  final Random rng;
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double opacity;
  late double size;
  late double life;
  late double maxLife;

  _Particle(this.rng) {
    _reset();
  }

  void _reset() {
    // Nacen en el centro con dispersión
    x = 0.5 + (rng.nextDouble() - 0.5) * 0.2;
    y = 0.45 + (rng.nextDouble() - 0.5) * 0.15;
    final angle = rng.nextDouble() * 2 * pi;
    final speed = 0.0008 + rng.nextDouble() * 0.0015;
    vx = cos(angle) * speed;
    vy = sin(angle) * speed - 0.002; // tendencia hacia arriba
    opacity = 0.6 + rng.nextDouble() * 0.4;
    size = 2 + rng.nextDouble() * 4;
    maxLife = 40 + rng.nextDouble() * 60;
    life = rng.nextDouble() * maxLife;
  }

  void update() {
    x += vx;
    y += vy;
    vy -= 0.00008; // aceleración hacia arriba
    life++;
    opacity -= 0.012;
    size *= 0.985;
    if (life > maxLife || opacity <= 0 || size < 0.5) {
      _reset();
      life = 0;
      opacity = 0.6 + rng.nextDouble() * 0.4;
    }
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Size screenSize;

  _ParticlePainter(this.particles, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final px = p.x * screenSize.width;
      final py = p.y * screenSize.height;
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFFEF233C),
          const Color(0xFFFF6B00),
          (1 - p.opacity).clamp(0.0, 1.0),
        )!
            .withOpacity(p.opacity.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(px, py), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ─────────────────────────────────────────────
// ANILLO GIRATORIO CON DASHES Y RUNAS
// ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashes;
  final double glowIntensity;
  final bool runeMarks;

  const _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashes,
    required this.glowIntensity,
    this.runeMarks = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.47;

    // Glow exterior del anillo
    final glowPaint = Paint()
      ..color = color.withOpacity(0.15 + 0.25 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + 6 * glowIntensity);
    canvas.drawCircle(Offset(cx, cy), r, glowPaint);

    // Dashes del anillo
    final dashAngle = (2 * pi) / dashes;
    final gapFrac = 0.35;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < dashes; i++) {
      final start = dashAngle * i;
      final sweep = dashAngle * (1 - gapFrac);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start,
        sweep,
        false,
        paint,
      );
    }

    // Marcas de runa en los nodos
    if (runeMarks) {
      final nodePaint = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      for (int i = 0; i < dashes; i++) {
        final angle = dashAngle * i;
        final nx = cx + r * cos(angle);
        final ny = cy + r * sin(angle);
        canvas.drawCircle(Offset(nx, ny), strokeWidth * 2, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.glowIntensity != glowIntensity;
}

// ─────────────────────────────────────────────
// PENTAGRAMA CON CÍRCULO Y OJO CENTRAL
// ─────────────────────────────────────────────
class _PentagramPainter extends CustomPainter {
  final double glowIntensity;

  const _PentagramPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;

    // Glow fondo
    final bgPaint = Paint()
      ..color = const Color(0xFFB71C1C).withOpacity(0.12 + 0.1 * glowIntensity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 + 10 * glowIntensity);
    canvas.drawCircle(Offset(cx, cy), r * 0.8, bgPaint);

    // Círculo exterior
    final circlePaint = Paint()
      ..color = const Color(0xFFB71C1C).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), r, circlePaint);

    // Pentagrama (estrella de 5 puntas)
    final pentPath = Path();
    const points = 5;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final radius = i.isEven ? r : r * 0.38;
      final px = cx + radius * cos(angle);
      final py = cy + radius * sin(angle);
      if (i == 0) {
        pentPath.moveTo(px, py);
      } else {
        pentPath.lineTo(px, py);
      }
    }
    pentPath.close();

    final pentGlow = Paint()
      ..color = const Color(0xFFEF233C).withOpacity(0.3 + 0.2 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(pentPath, pentGlow);

    final pentPaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pentPath, pentPaint);

    // Ojo de fuego central
    final eyeR = r * 0.22;
    // Iris exterior
    final irisGlow = Paint()
      ..color = const Color(0xFFEF233C).withOpacity(0.4 + 0.4 * glowIntensity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + 8 * glowIntensity);
    canvas.drawCircle(Offset(cx, cy), eyeR, irisGlow);

    // Iris sólido
    final irisPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFEF233C),
          const Color(0xFF7A0000),
          Colors.black,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: eyeR));
    canvas.drawCircle(Offset(cx, cy), eyeR, irisPaint);

    // Pupila
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx, cy), eyeR * 0.4, pupilPaint);

    // Brillo del ojo
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(
      Offset(cx - eyeR * 0.25, cy - eyeR * 0.25),
      eyeR * 0.12,
      shinePaint,
    );

    // Pestañas / rayos del ojo
    final rayPaint = Paint()
      ..color = const Color(0xFFEF233C).withOpacity(0.6)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final innerR = eyeR + 4;
      final outerR = eyeR + 10 + 5 * glowIntensity;
      canvas.drawLine(
        Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
        Offset(cx + outerR * cos(angle), cy + outerR * sin(angle)),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PentagramPainter old) =>
      old.glowIntensity != glowIntensity;
}
