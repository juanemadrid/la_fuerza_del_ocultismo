import 'dart:math';
import 'package:flutter/material.dart';

class OccultLogo extends StatefulWidget {
  final double size;
  const OccultLogo({super.key, this.size = 110});

  @override
  State<OccultLogo> createState() => _OccultLogoState();
}

class _OccultLogoState extends State<OccultLogo> with TickerProviderStateMixin {
  late AnimationController _blinkCtrl;
  late AnimationController _pulseCtrl;
  // Mirada: el ojo vigila a los lados, como espiando.
  late AnimationController _gazeCtrl;
  late Animation<double> _gaze;

  late Animation<double> _eyeOpenAmount;
  late Animation<double> _pulseAmount;

  @override
  void initState() {
    super.initState();

    // Pulse: continuous mistic glow
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAmount = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Blink: periodically blinks (closes and opens)
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();

    // Parpadeo lento e inquietante: abierto casi todo el tiempo,
    // un parpadeo rápido y, a veces, uno doble.
    _eyeOpenAmount = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 80.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 3.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 5.0),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 4.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 3.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 5.0),
    ]).animate(_blinkCtrl);

    // Mirada: centro → izquierda (se queda) → derecha (se queda) → centro.
    _gazeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat();
    _gaze = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 18),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: -1.0)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 6),
      TweenSequenceItem(tween: ConstantTween<double>(-1.0), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: -1.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 8),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 6),
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 22),
    ]).animate(_gazeCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _blinkCtrl.dispose();
    _gazeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkCtrl, _pulseCtrl, _gazeCtrl]),
      builder: (context, _) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB71C1C).withValues(
                  alpha: 0.12 + 0.18 * _pulseAmount.value,
                ),
                blurRadius: widget.size * 0.3,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _OccultLogoPainter(
              eyeOpen: _eyeOpenAmount.value,
              pulse: _pulseAmount.value,
              gaze: _gaze.value,
            ),
          ),
        );
      },
    );
  }
}

class _OccultLogoPainter extends CustomPainter {
  final double eyeOpen;
  final double pulse;
  final double gaze; // -1 mira a la izquierda, 0 al frente, 1 a la derecha

  _OccultLogoPainter(
      {required this.eyeOpen, required this.pulse, required this.gaze});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44; // outer circle radius

    // 1. Círculo exterior
    final circlePaint = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.012;
    canvas.drawCircle(Offset(cx, cy), r, circlePaint);

    final innerR = r * 0.85;
    final innerPaint = Paint()
      ..color = const Color(0xFFB71C1C).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.007;
    canvas.drawCircle(Offset(cx, cy), innerR, innerPaint);

    // 2. Pentagrama invertido (Estrella de 5 puntas con punta hacia abajo)
    final pts = List.generate(5, (i) {
      final angle = (pi / 2) + (i * 4 * pi / 5);
      return Offset(cx + innerR * cos(angle), cy + innerR * sin(angle));
    });

    final pentPaint = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.012
      ..strokeJoin = StrokeJoin.round;

    final pentPath = Path();
    pentPath.moveTo(pts[0].dx, pts[0].dy);
    pentPath.lineTo(pts[2].dx, pts[2].dy);
    pentPath.lineTo(pts[4].dx, pts[4].dy);
    pentPath.lineTo(pts[1].dx, pts[1].dy);
    pentPath.lineTo(pts[3].dx, pts[3].dy);
    pentPath.close();

    canvas.drawPath(pentPath, pentPaint);

    // Brillo en los vértices del pentagrama
    for (final pt in pts) {
      final vtxPaint = Paint()
        ..color = const Color(0xFFEF233C).withValues(alpha: 0.7 + 0.3 * pulse);
      canvas.drawCircle(pt, size.width * 0.022, vtxPaint);
    }

    // 3. Ojo central que parpadea
    final ew = size.width * 0.22; // semi-ancho del ojo
    final eh = size.height * 0.17 * eyeOpen; // semi-alto del ojo

    if (eh >= 0.1) {
      final eyePath = Path();
      eyePath.moveTo(cx - ew, cy);
      eyePath.cubicTo(cx - ew * 0.5, cy - eh * 1.25, cx + ew * 0.5, cy - eh * 1.25, cx + ew, cy);
      eyePath.cubicTo(cx + ew * 0.5, cy + eh * 1.25, cx - ew * 0.5, cy + eh * 1.25, cx - ew, cy);
      eyePath.close();

      canvas.save();
      canvas.clipPath(eyePath);

      // Fondo negro del ojo
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black);

      // Iris rojo sangre en anillos (sin degradado: más liviano en iPhone).
      // Su tamaño no depende del parpadeo, así el párpado lo tapa al cerrar.
      final irisR = size.height * 0.17 * 0.85;
      final ix = cx + gaze * ew * 0.42; // el iris se desplaza al mirar
      final irisC = Offset(ix, cy);
      canvas.drawCircle(irisC, irisR, Paint()..color = const Color(0xFF3D0000));
      canvas.drawCircle(
          irisC, irisR * 0.78, Paint()..color = const Color(0xFF8B0000));
      canvas.drawCircle(irisC, irisR * 0.5,
          Paint()..color = const Color(0xFFEF233C).withValues(alpha: 0.85 + 0.15 * pulse));

      // Pupila vertical de demonio/gato
      final pupilW = irisR * (0.16 + 0.06 * pulse);
      final pupilH = irisR * 0.8;
      canvas.drawOval(
        Rect.fromCenter(center: irisC, width: pupilW * 2, height: pupilH * 2),
        Paint()..color = Colors.black,
      );

      // Brillos del ojo
      canvas.drawCircle(
        Offset(ix - irisR * 0.28, cy - irisR * 0.28),
        irisR * 0.12,
        Paint()..color = Colors.white.withValues(alpha: 0.6 + 0.2 * pulse),
      );

      canvas.restore();

      // Borde del ojo
      final outlinePaint = Paint()
        ..color = const Color(0xFF8B0000).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.008;
      canvas.drawPath(eyePath, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OccultLogoPainter oldDelegate) {
    return oldDelegate.eyeOpen != eyeOpen ||
        oldDelegate.pulse != pulse ||
        oldDelegate.gaze != gaze;
  }
}
