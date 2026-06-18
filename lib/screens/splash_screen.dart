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
  // Master — orquesta 5.5 segundos totales
  late AnimationController _master;
  // Ojo — controla la apertura del párpado
  late AnimationController _eyeCtrl;
  // Pulso del iris
  late AnimationController _pulseCtrl;
  // Gotas de sangre
  late AnimationController _dripsCtrl;
  // Humo / partículas
  late AnimationController _smokeCtrl;

  late Animation<double> _bgFade;
  late Animation<double> _pentagramDraw;   // 0→1: trazo del pentagrama
  late Animation<double> _circleReveal;
  late Animation<double> _eyeOpen;         // 0→1: apertura del ojo
  late Animation<double> _textReveal;
  late Animation<double> _runesReveal;

  final List<_BloodDrip> _drips = [];
  final List<_SmokeParticle> _smoke = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _spawnDrips();
    _spawnSmoke();

    // ── Master ──
    _master = AnimationController(vsync: this, duration: const Duration(milliseconds: 5500));

    _bgFade = CurvedAnimation(parent: _master,
        curve: const Interval(0.00, 0.12, curve: Curves.easeIn));

    _circleReveal = CurvedAnimation(parent: _master,
        curve: const Interval(0.08, 0.30, curve: Curves.easeOut));

    _pentagramDraw = CurvedAnimation(parent: _master,
        curve: const Interval(0.18, 0.62, curve: Curves.easeInOut));

    _eyeOpen = CurvedAnimation(parent: _master,
        curve: const Interval(0.55, 0.82, curve: Curves.easeInOutCubic));

    _runesReveal = CurvedAnimation(parent: _master,
        curve: const Interval(0.65, 0.82, curve: Curves.easeOut));

    _textReveal = CurvedAnimation(parent: _master,
        curve: const Interval(0.78, 0.96, curve: Curves.easeOut));

    // ── Pulso del iris ──
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);

    // ── Gotas ──
    _dripsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 50))
      ..addListener(() => setState(() { for (final d in _drips) d.update(); }))
      ..repeat();

    // ── Humo ──
    _smokeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 80))
      ..addListener(() => setState(() { for (final s in _smoke) s.update(_rng); }))
      ..repeat();

    _master.forward();
    Future.delayed(const Duration(milliseconds: 5900), _navigate);
  }

  void _spawnDrips() {
    for (int i = 0; i < 10; i++) {
      _drips.add(_BloodDrip(_rng));
    }
  }

  void _spawnSmoke() {
    for (int i = 0; i < 18; i++) {
      _smoke.add(_SmokeParticle(_rng));
    }
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) { _goTo(const LoginScreen()); return; }
    await DatabaseService().checkAndUpdateExpiredSubscription(currentUser.uid);
    if (!mounted) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.reloadCurrentUser();
    if (!mounted) return;
    final user = authService.userModel;
    if (user == null) { _goTo(const LoginScreen()); return; }
    if (user.role == 'admin') { _goTo(const AdminDashboard()); return; }
    if (user.pendingApproval && user.subscriptionExpiry == null && user.pendingPlanId == null) {
      _goTo(const SelectPlanScreen()); return;
    }
    if (user.pendingApproval && user.subscriptionExpiry == null) {
      _goTo(const PendingApprovalScreen()); return;
    }
    user.isMembershipActive ? _goTo(const HomeScreen()) : _goTo(const MembresiaVencidaScreen());
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 1000),
    ));
  }

  @override
  void dispose() {
    _master.dispose();
    _pulseCtrl.dispose();
    _dripsCtrl.dispose();
    _smokeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_master, _pulseCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              // ── 1. Fondo: oscuridad absoluta con velo rojo profundo ──
              Opacity(
                opacity: _bgFade.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.8,
                      colors: [Color(0xFF0F0000), Color(0xFF050000), Colors.black],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // ── 2. Humo oscuro en la parte baja ──
              if (_bgFade.value > 0.5)
                Opacity(
                  opacity: ((_bgFade.value - 0.5) * 2).clamp(0.0, 0.5),
                  child: CustomPaint(
                    size: size,
                    painter: _SmokePainter(_smoke, size),
                  ),
                ),

              // ── 3. Gotas de sangre desde arriba ──
              if (_pentagramDraw.value > 0.1)
                Opacity(
                  opacity: ((_pentagramDraw.value - 0.1) / 0.9).clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: size,
                    painter: _BloodDripsPainter(_drips, size),
                  ),
                ),

              // ── 4. Círculo ritual + pentagrama invertido ──
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Aura roja pulsante
                    if (_circleReveal.value > 0)
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB71C1C).withOpacity(
                                0.08 + 0.12 * _pulseCtrl.value * _eyeOpen.value,
                              ),
                              blurRadius: 60 + 30 * _pulseCtrl.value,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),

                    // Círculo exterior (se dibuja)
                    if (_circleReveal.value > 0)
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: _ArcRevealPainter(
                          progress: _circleReveal.value,
                          color: const Color(0xFF6B0000),
                          strokeWidth: 1.0,
                        ),
                      ),

                    // Círculo interior
                    if (_circleReveal.value > 0.5)
                      CustomPaint(
                        size: const Size(188, 188),
                        painter: _ArcRevealPainter(
                          progress: ((_circleReveal.value - 0.5) * 2).clamp(0, 1),
                          color: const Color(0xFF8B0000),
                          strokeWidth: 0.6,
                        ),
                      ),

                    // Pentagrama INVERTIDO que se dibuja trazo a trazo
                    if (_pentagramDraw.value > 0)
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: _InvertedPentagramPainter(
                          progress: _pentagramDraw.value,
                          glowPulse: _pulseCtrl.value,
                        ),
                      ),

                    // Ojo que se abre en el centro
                    if (_eyeOpen.value > 0)
                      CustomPaint(
                        size: const Size(110, 60),
                        painter: _EyePainter(
                          openAmount: _eyeOpen.value,
                          pulsate: _pulseCtrl.value,
                        ),
                      ),

                    // Runas alrededor del círculo
                    if (_runesReveal.value > 0)
                      Opacity(
                        opacity: _runesReveal.value,
                        child: CustomPaint(
                          size: const Size(220, 220),
                          painter: _RunesPainter(
                            opacity: _runesReveal.value,
                            pulse: _pulseCtrl.value,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── 5. Texto: aparece desde abajo ──
              Positioned(
                bottom: size.height * 0.18,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _textReveal.value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - _textReveal.value)),
                    child: Column(
                      children: [
                        // Líneas de sangre
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _bloodLine(40),
                            const SizedBox(width: 16),
                            Text('LA FUERZA',
                              style: GoogleFonts.cinzel(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                              ),
                            ),
                            const SizedBox(width: 16),
                            _bloodLine(40),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('DEL  OCULTISMO',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFF8B0000),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Punto parpadeante
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => Opacity(
                            opacity: 0.3 + 0.7 * _pulseCtrl.value,
                            child: Text('· · ·',
                              style: TextStyle(
                                color: const Color(0xFF8B0000),
                                fontSize: 10,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bloodLine(double width) {
    return Container(
      width: width,
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0xFF8B0000)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PENTAGRAMA INVERTIDO — se dibuja trazo a trazo
// ─────────────────────────────────────────────
class _InvertedPentagramPainter extends CustomPainter {
  final double progress;
  final double glowPulse;
  _InvertedPentagramPainter({required this.progress, required this.glowPulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;

    // Los 5 puntos del pentagrama INVERTIDO (punta hacia abajo)
    // Empezando desde el punto de abajo, girando clockwise para el aspecto invertido
    final pts = List.generate(5, (i) {
      final angle = (pi / 2) + (i * 4 * pi / 5); // invertido: empieza abajo
      return Offset(cx + r * cos(angle), cy + r * sin(angle));
    });

    // El pentagrama tiene 5 líneas. Las dibujamos una por una según progress
    // Orden de trazado: pts[0]→pts[2]→pts[4]→pts[1]→pts[3]→pts[0]
    final segments = [
      [pts[0], pts[2]],
      [pts[2], pts[4]],
      [pts[4], pts[1]],
      [pts[1], pts[3]],
      [pts[3], pts[0]],
    ];

    final totalSegs = segments.length;
    final drawn = progress * totalSegs;

    for (int i = 0; i < totalSegs; i++) {
      if (drawn <= i) break;
      final segProgress = (drawn - i).clamp(0.0, 1.0);
      final p1 = segments[i][0];
      final p2 = segments[i][1];
      final endPt = Offset(
        p1.dx + (p2.dx - p1.dx) * segProgress,
        p1.dy + (p2.dy - p1.dy) * segProgress,
      );

      // Glow del trazo
      final glowPaint = Paint()
        ..color = const Color(0xFFB71C1C).withOpacity(0.25 + 0.15 * glowPulse)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawLine(p1, endPt, glowPaint);

      // Línea principal
      final linePaint = Paint()
        ..color = const Color(0xFF8B0000).withOpacity(0.9)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, endPt, linePaint);
    }

    // Puntos de vértice con glow
    for (int i = 0; i < totalSegs; i++) {
      if (drawn < i) break;
      final vtxPaint = Paint()
        ..color = const Color(0xFFEF233C).withOpacity(0.85)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + 3 * glowPulse);
      canvas.drawCircle(segments[i][0], 2.5, vtxPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InvertedPentagramPainter old) =>
      old.progress != progress || old.glowPulse != glowPulse;
}

// ─────────────────────────────────────────────
// OJO QUE SE ABRE LENTAMENTE
// ─────────────────────────────────────────────
class _EyePainter extends CustomPainter {
  final double openAmount; // 0=cerrado, 1=abierto
  final double pulsate;

  _EyePainter({required this.openAmount, required this.pulsate});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final ew = size.width * 0.5;   // semi-ancho ojo
    final eh = size.height * 0.46 * openAmount; // semi-alto (crece al abrir)

    if (eh < 0.5) return;

    // Forma del ojo: path almendrado
    final eyePath = Path();
    eyePath.moveTo(cx - ew, cy);
    eyePath.cubicTo(cx - ew * 0.5, cy - eh * 1.2, cx + ew * 0.5, cy - eh * 1.2, cx + ew, cy);
    eyePath.cubicTo(cx + ew * 0.5, cy + eh * 1.2, cx - ew * 0.5, cy + eh * 1.2, cx - ew, cy);
    eyePath.close();

    // Clip al ojo
    canvas.save();
    canvas.clipPath(eyePath);

    // Fondo del ojo: negro absoluto
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.black);

    // Iris rojo sangre
    final irisR = eh * 0.85;
    final irisShader = RadialGradient(
      colors: [
        const Color(0xFFEF233C),
        const Color(0xFF8B0000),
        const Color(0xFF3D0000),
        Colors.black,
      ],
      stops: const [0.0, 0.35, 0.65, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: irisR));
    canvas.drawCircle(Offset(cx, cy), irisR, Paint()..shader = irisShader);

    // Pupila vertical (como ojo de gato/demonio)
    final pupilW = irisR * (0.18 + 0.08 * pulsate);
    final pupilH = irisR * 0.82;
    final pupilPath = Path();
    pupilPath.addOval(Rect.fromCenter(
      center: Offset(cx, cy),
      width: pupilW * 2,
      height: pupilH * 2,
    ));
    canvas.drawPath(pupilPath, Paint()..color = Colors.black);

    // Destellos del iris
    canvas.drawCircle(
      Offset(cx - irisR * 0.3, cy - irisR * 0.3),
      irisR * 0.1,
      Paint()..color = Colors.white.withOpacity(0.5 + 0.3 * pulsate),
    );
    canvas.drawCircle(
      Offset(cx + irisR * 0.15, cy - irisR * 0.45),
      irisR * 0.05,
      Paint()..color = Colors.white.withOpacity(0.3),
    );

    canvas.restore();

    // Borde del ojo — delineado rojo
    final outlinePaint = Paint()
      ..color = const Color(0xFF8B0000).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(eyePath, outlinePaint);

    // Glow exterior
    final glowPaint = Paint()
      ..color = const Color(0xFFB71C1C).withOpacity(0.15 + 0.2 * pulsate * openAmount)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(eyePath, glowPaint);

    // Pestañas superiores
    if (openAmount > 0.5) {
      final lashPaint = Paint()
        ..color = const Color(0xFF5A0000).withOpacity((openAmount - 0.5) * 2)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 7; i++) {
        final t = i / 6.0;
        final lx = cx - ew + ew * 2 * t;
        final baseY = cy - eh * 1.15 * _eyelidCurve(t);
        final tip = baseY - 8 - 4 * sin(t * pi);
        canvas.drawLine(Offset(lx, baseY), Offset(lx + 2, tip), lashPaint);
      }
    }
  }

  double _eyelidCurve(double t) => sin(t * pi).clamp(0.0, 1.0);

  @override
  bool shouldRepaint(covariant _EyePainter old) =>
      old.openAmount != openAmount || old.pulsate != pulsate;
}

// ─────────────────────────────────────────────
// CÍRCULO QUE SE DIBUJA
// ─────────────────────────────────────────────
class _ArcRevealPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  _ArcRevealPainter({required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcRevealPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
// RUNAS ALREDEDOR DEL CÍRCULO
// ─────────────────────────────────────────────
class _RunesPainter extends CustomPainter {
  final double opacity;
  final double pulse;
  static const _runeChars = ['ᚠ', 'ᚢ', 'ᚦ', 'ᚨ', 'ᚱ', 'ᚲ', 'ᚷ', 'ᚹ', 'ᚺ', 'ᚾ', 'ᛁ', 'ᛃ'];

  _RunesPainter({required this.opacity, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;
    final count = _runeChars.length;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi - pi / 2;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: _runeChars[i],
          style: TextStyle(
            color: const Color(0xFF5A0000).withOpacity(opacity * (0.6 + 0.4 * pulse)),
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RunesPainter old) => old.opacity != opacity || old.pulse != pulse;
}

// ─────────────────────────────────────────────
// GOTAS DE SANGRE
// ─────────────────────────────────────────────
class _BloodDrip {
  late double x;
  late double y;
  late double speed;
  late double size;
  late double length;
  late double opacity;
  late bool pooled;

  _BloodDrip(Random rng) { _reset(rng); }

  void _reset(Random rng) {
    x = rng.nextDouble();
    y = -(rng.nextDouble() * 0.3);
    speed = 0.0008 + rng.nextDouble() * 0.0015;
    size = 3 + rng.nextDouble() * 5;
    length = 10 + rng.nextDouble() * 40;
    opacity = 0.5 + rng.nextDouble() * 0.5;
    pooled = false;
  }

  void update() {
    if (pooled) return;
    y += speed;
    if (y > 1.05) pooled = true;
  }
}

class _BloodDripsPainter extends CustomPainter {
  final List<_BloodDrip> drips;
  final Size screen;
  _BloodDripsPainter(this.drips, this.screen);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF8B0000);

    for (final d in drips) {
      if (d.pooled) continue;
      final px = d.x * screen.width;
      final py = d.y * screen.height;

      // Línea (cola de la gota)
      final tailPaint = Paint()
        ..color = const Color(0xFF6B0000).withOpacity(d.opacity * 0.6)
        ..strokeWidth = d.size * 0.35
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(px, (d.y - d.length / screen.height) * screen.height),
        Offset(px, py),
        tailPaint,
      );

      // Cabeza circular
      final dropPaint = Paint()
        ..color = const Color(0xFF8B0000).withOpacity(d.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(px, py), d.size * 0.5, dropPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ─────────────────────────────────────────────
// HUMO OSCURO
// ─────────────────────────────────────────────
class _SmokeParticle {
  late double x, y, vx, vy, opacity, size, life, maxLife;

  _SmokeParticle(Random rng) { _reset(rng); }

  void _reset(Random rng) {
    x = 0.2 + rng.nextDouble() * 0.6;
    y = 0.75 + rng.nextDouble() * 0.25;
    vx = (rng.nextDouble() - 0.5) * 0.001;
    vy = -(0.0005 + rng.nextDouble() * 0.001);
    opacity = 0.04 + rng.nextDouble() * 0.06;
    size = 30 + rng.nextDouble() * 50;
    maxLife = 80 + rng.nextDouble() * 60;
    life = rng.nextDouble() * maxLife;
  }

  void update(Random rng) {
    x += vx;
    y += vy;
    size += 0.4;
    opacity -= 0.0006;
    life++;
    if (life > maxLife || opacity <= 0) _reset(rng);
  }
}

class _SmokePainter extends CustomPainter {
  final List<_SmokeParticle> particles;
  final Size screen;
  _SmokePainter(this.particles, this.screen);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = const Color(0xFF1A0000).withOpacity(p.opacity.clamp(0, 0.15))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.4);
      canvas.drawCircle(
        Offset(p.x * screen.width, p.y * screen.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
