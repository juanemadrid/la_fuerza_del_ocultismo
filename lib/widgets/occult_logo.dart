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
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _eyeOpenAmount = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 70.0, // Stays open for 70% of time (approx 1.26s)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10.0, // Closes quickly (approx 0.18s)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0, // Opens back up (approx 0.36s)
      ),
    ]).animate(_blinkCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkCtrl, _pulseCtrl]),
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

  _OccultLogoPainter({required this.eyeOpen, required this.pulse});

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
        ..color = const Color(0xFFEF233C).withValues(alpha: 0.7 + 0.3 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.02);
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

      // Iris rojo sangre gradiente
      final irisR = eh * 0.85;
       final irisShader = const RadialGradient(
        colors: [
          Color(0xFFEF233C),
          Color(0xFF8B0000),
          Color(0xFF3D0000),
          Colors.black,
        ],
        stops: [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: irisR));
      canvas.drawCircle(Offset(cx, cy), irisR, Paint()..shader = irisShader);

      // Pupila vertical de demonio/gato
      final pupilW = irisR * (0.16 + 0.06 * pulse);
      final pupilH = irisR * 0.8;
      final pupilPath = Path();
      pupilPath.addOval(Rect.fromCenter(
        center: Offset(cx, cy),
        width: pupilW * 2,
        height: pupilH * 2,
      ));
      canvas.drawPath(pupilPath, Paint()..color = Colors.black);

      // Brillos del ojo
      canvas.drawCircle(
        Offset(cx - irisR * 0.28, cy - irisR * 0.28),
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
    return oldDelegate.eyeOpen != eyeOpen || oldDelegate.pulse != pulse;
  }
}
