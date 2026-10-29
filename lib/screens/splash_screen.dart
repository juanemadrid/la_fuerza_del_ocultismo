import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _master;
  late AnimationController _pulseCtrl;
  late AnimationController _dripsCtrl;
  late AnimationController _smokeCtrl;

  late Animation<double> _bgFade;
  late Animation<double> _circleReveal;
  late Animation<double> _pentagramDraw;
  late Animation<double> _eyeOpenAmount;
  late Animation<double> _runesReveal;
  late Animation<double> _textReveal;

  final List<_BloodDrip> _drips = [];
  final List<_SmokeParticle> _smoke = [];
  final Random _rng = Random();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _spawnDrips();
    _spawnSmoke();

    // ── 1. Master Controller (dibujo del círculo, estrella, ojo, runas y título) ──
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    _bgFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.00, 0.15, curve: Curves.easeIn),
    );

    _circleReveal = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.06, 0.34, curve: Curves.easeOut),
    );

    _pentagramDraw = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.16, 0.58, curve: Curves.easeInOut),
    );

    _eyeOpenAmount = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 55.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 45.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.46, 0.95),
      ),
    );

    _runesReveal = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.52, 0.78, curve: Curves.easeOut),
    );

    _textReveal = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.62, 0.90, curve: Curves.easeOut),
    );

    // ── 2. Loop Controllers ──
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _dripsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(() {
        if (mounted && !_navigated) {
          setState(() {
            for (final d in _drips) {
              d.update();
            }
          });
        }
      })
      ..repeat();

    _smokeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..addListener(() {
        if (mounted && !_navigated) {
          setState(() {
            for (final s in _smoke) {
              s.update(_rng);
            }
          });
        }
      })
      ..repeat();

    _master.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitAndNavigate();
    });
  }

  void _spawnDrips() {
    for (int i = 0; i < 10; i++) {
      _drips.add(_BloodDrip(_rng));
    }
  }

  void _spawnSmoke() {
    for (int i = 0; i < 14; i++) {
      _smoke.add(_SmokeParticle(_rng));
    }
  }

  Future<void> _waitAndNavigate() async {
    // Esperamos a que se complete la animación del sello/estrella/ojo
    // (3.4s es suficiente también para que IndexedDB restaure la sesión en móvil)
    await Future.delayed(const Duration(milliseconds: 3450));
    if (!mounted || _navigated) return;

    Widget targetScreen = const LoginScreen();

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        try {
          currentUser = await FirebaseAuth.instance
              .authStateChanges()
              .first
              .timeout(const Duration(milliseconds: 300));
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
    _master.stop();
    _pulseCtrl.stop();
    _dripsCtrl.stop();
    _smokeCtrl.stop();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => targetScreen),
    );
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
      backgroundColor: const Color(0xFF050000),
      body: AnimatedBuilder(
        animation: Listenable.merge([_master, _pulseCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              // ── 1. Fondo gradiente radial ──
              Opacity(
                opacity: _bgFade.value.clamp(0.2, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.8,
                      colors: [
                        Color(0xFF160000),
                        Color(0xFF070000),
                        Colors.black,
                      ],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // ── 2. Humo oscuro en la parte inferior (sin MaskFilter.blur para no colgar WebGL móvil) ──
              if (_bgFade.value > 0.4)
                Opacity(
                  opacity: ((_bgFade.value - 0.4) * 1.5).clamp(0.0, 0.5),
                  child: CustomPaint(
                    size: size,
                    painter: _SmokePainter(_smoke, size),
                  ),
                ),

              // ── 3. Gotas de sangre cayendo ──
              if (_pentagramDraw.value > 0.1)
                Opacity(
                  opacity: ((_pentagramDraw.value - 0.1) / 0.9).clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: size,
                    painter: _BloodDripsPainter(_drips, size),
                  ),
                ),

              // ── 4. Portal Ritual (Círculos, Pentagrama/Estrella, Runas, Ojo) ──
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Aura central roja pulsante
                    if (_circleReveal.value > 0)
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFB71C1C).withOpacity(
                                (0.12 +
                                        0.14 *
                                            _pulseCtrl.value *
                                            _eyeOpenAmount.value)
                                    .clamp(0.0, 0.35),
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                    // Círculo exterior que se va llenando
                    if (_circleReveal.value > 0)
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: _ArcRevealPainter(
                          progress: _circleReveal.value,
                          color: const Color(0xFF8B0000),
                          strokeWidth: 1.4,
                        ),
                      ),

                    // Círculo interior que se va llenando
                    if (_circleReveal.value > 0.4)
                      CustomPaint(
                        size: const Size(188, 188),
                        painter: _ArcRevealPainter(
                          progress:
                              ((_circleReveal.value - 0.4) / 0.6).clamp(0.0, 1.0),
                          color: const Color(0xFFB71C1C),
                          strokeWidth: 0.9,
                        ),
                      ),

                    // Pentagrama Invertido (Estrella que se dibuja trazo a trazo)
                    if (_pentagramDraw.value > 0)
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: _InvertedPentagramPainter(
                          progress: _pentagramDraw.value,
                          glowPulse: _pulseCtrl.value,
                        ),
                      ),

                    // Ojo en el centro que se abre
                    if (_eyeOpenAmount.value > 0.01)
                      CustomPaint(
                        size: const Size(110, 60),
                        painter: _EyePainter(
                          openAmount: _eyeOpenAmount.value,
                          pulsate: _pulseCtrl.value,
                        ),
                      ),

                    // Runas misteriosas alrededor del círculo
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

              // ── 5. Texto del Título ──
              Positioned(
                bottom: size.height * 0.16,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _textReveal.value,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - _textReveal.value)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _bloodLine(40),
                            const SizedBox(width: 16),
                            Text(
                              'LA FUERZA',
                              style: GoogleFonts.cinzel(
                                color: Colors.white.withOpacity(0.94),
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
                        Text(
                          'DEL  OCULTISMO',
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFB71C1C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Opacity(
                          opacity: (0.35 + 0.65 * _pulseCtrl.value).clamp(0.0, 1.0),
                          child: const Text(
                            '· · ·',
                            style: TextStyle(
                              color: Color(0xFF8B0000),
                              fontSize: 10,
                              letterSpacing: 6,
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
// CUSTOM PAINTERS (Optimizados sin MaskFilter.blur para compatibilidad total en WebGL móvil)
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

    final pts = List.generate(5, (i) {
      final angle = (pi / 2) + (i * 4 * pi / 5);
      return Offset(cx + r * cos(angle), cy + r * sin(angle));
    });

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

      // Halo exterior suave (sin MaskFilter.blur)
      final outerGlowPaint = Paint()
        ..color = const Color(0xFFB71C1C).withOpacity(0.14 + 0.10 * glowPulse)
        ..strokeWidth = 9
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, endPt, outerGlowPaint);

      final midGlowPaint = Paint()
        ..color = const Color(0xFFD90429).withOpacity(0.24 + 0.12 * glowPulse)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, endPt, midGlowPaint);

      final linePaint = Paint()
        ..color = const Color(0xFFEF233C).withOpacity(0.95)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, endPt, linePaint);
    }

    for (int i = 0; i < totalSegs; i++) {
      if (drawn < i) break;
      final vtxGlowPaint = Paint()
        ..color = const Color(0xFFEF233C).withOpacity(0.28 + 0.15 * glowPulse);
      canvas.drawCircle(segments[i][0], 5.5, vtxGlowPaint);

      final vtxPaint = Paint()
        ..color = const Color(0xFFFF4D6D).withOpacity(0.9);
      canvas.drawCircle(segments[i][0], 2.5, vtxPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InvertedPentagramPainter old) =>
      old.progress != progress || old.glowPulse != glowPulse;
}

class _EyePainter extends CustomPainter {
  final double openAmount;
  final double pulsate;

  _EyePainter({required this.openAmount, required this.pulsate});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final ew = size.width * 0.5;
    final eh = size.height * 0.46 * openAmount;

    if (eh < 0.5) return;

    final eyePath = Path();
    eyePath.moveTo(cx - ew, cy);
    eyePath.cubicTo(
      cx - ew * 0.5,
      cy - eh * 1.2,
      cx + ew * 0.5,
      cy - eh * 1.2,
      cx + ew,
      cy,
    );
    eyePath.cubicTo(
      cx + ew * 0.5,
      cy + eh * 1.2,
      cx - ew * 0.5,
      cy + eh * 1.2,
      cx - ew,
      cy,
    );
    eyePath.close();

    canvas.save();
    canvas.clipPath(eyePath);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    final irisR = eh * 0.85;
    if (irisR > 1.0) {
      final irisShader = RadialGradient(
        colors: const [
          Color(0xFFEF233C),
          Color(0xFF8B0000),
          Color(0xFF3D0000),
          Colors.black,
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: irisR));
      canvas.drawCircle(Offset(cx, cy), irisR, Paint()..shader = irisShader);

      final pupilW = irisR * (0.18 + 0.08 * pulsate);
      final pupilH = irisR * 0.82;
      final pupilPath = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: pupilW * 2,
            height: pupilH * 2,
          ),
        );
      canvas.drawPath(pupilPath, Paint()..color = Colors.black);

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
    }

    canvas.restore();

    // Halo exterior del ojo (sin MaskFilter.blur)
    final glowPaint = Paint()
      ..color =
          const Color(0xFFB71C1C).withOpacity(0.16 + 0.16 * pulsate * openAmount)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawPath(eyePath, glowPaint);

    final outlinePaint = Paint()
      ..color = const Color(0xFFEF233C).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(eyePath, outlinePaint);

    if (openAmount > 0.5) {
      final lashPaint = Paint()
        ..color = const Color(0xFF8B0000).withOpacity((openAmount - 0.5) * 2)
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

class _ArcRevealPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  _ArcRevealPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final glowPaint = Paint()
      ..color = color.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 3.5;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, glowPaint);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcRevealPainter old) =>
      old.progress != progress;
}

class _RunesPainter extends CustomPainter {
  final double opacity;
  final double pulse;
  static const _runeChars = [
    'ᚠ',
    'ᚢ',
    'ᚦ',
    'ᚨ',
    'ᚱ',
    'ᚲ',
    'ᚷ',
    'ᚹ',
    'ᚺ',
    'ᚾ',
    'ᛁ',
    'ᛃ',
  ];

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
            color: const Color(0xFF8B0000)
                .withOpacity((opacity * (0.6 + 0.4 * pulse)).clamp(0.0, 1.0)),
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RunesPainter old) =>
      old.opacity != opacity || old.pulse != pulse;
}

class _BloodDrip {
  late double x;
  late double y;
  late double speed;
  late double size;
  late double length;
  late double opacity;
  late bool pooled;

  _BloodDrip(Random rng) {
    _reset(rng);
  }

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
    for (final d in drips) {
      if (d.pooled) continue;
      final px = d.x * screen.width;
      final py = d.y * screen.height;

      final tailPaint = Paint()
        ..color = const Color(0xFF6B0000).withOpacity(d.opacity * 0.6)
        ..strokeWidth = d.size * 0.35
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(px, (d.y - d.length / screen.height) * screen.height),
        Offset(px, py),
        tailPaint,
      );

      final dropPaint = Paint()
        ..color = const Color(0xFF8B0000).withOpacity(d.opacity);
      canvas.drawCircle(Offset(px, py), d.size * 0.5, dropPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _SmokeParticle {
  late double x, y, vx, vy, opacity, size, life, maxLife;

  _SmokeParticle(Random rng) {
    _reset(rng);
  }

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
      final center = Offset(p.x * screen.width, p.y * screen.height);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF220000).withOpacity(p.opacity.clamp(0.0, 0.15)),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: p.size));
      canvas.drawCircle(center, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
