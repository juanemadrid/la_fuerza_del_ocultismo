import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Humo ritual de incienso que sube desde abajo y se mece de un lado a otro.
///
/// Se dibuja solo con círculos de color sólido translúcido (sin degradados ni
/// desenfoques por cuadro) para que corra fluido también en iPhone y en
/// celulares de gama baja.
class RitualSmoke extends StatefulWidget {
  const RitualSmoke({super.key});

  @override
  State<RitualSmoke> createState() => _RitualSmokeState();
}

class _RitualSmokeState extends State<RitualSmoke>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Wisp> _wisps;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _wisps = List.generate(16, (i) => _Wisp(rng, i));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _SmokePainter(_ctrl.value, _wisps),
          ),
        ),
      ),
    );
  }
}

class _Wisp {
  final double startX; // posición horizontal de origen (0..1)
  final double phase; // desfase en el ciclo (0..1)
  final double speed; // vueltas por ciclo de animación
  final double sway; // amplitud del vaivén lateral (0..1 del ancho)
  final double size; // tamaño relativo
  final Color color;

  _Wisp(math.Random rng, int i)
      : startX = rng.nextDouble(),
        phase = rng.nextDouble(),
        speed = 1 + rng.nextInt(2).toDouble(),
        sway = 0.08 + rng.nextDouble() * 0.14,
        size = 0.7 + rng.nextDouble() * 0.8,
        color = i % 5 == 0
            ? const Color(0xFFD4AF37) // brillo dorado de brasa
            : (i % 3 == 0
                ? const Color(0xFF6B2E7A) // violeta oscuro
                : const Color(0xFF8B0000)); // rojo sangre
}

class _SmokePainter extends CustomPainter {
  final double t;
  final List<_Wisp> wisps;
  _SmokePainter(this.t, this.wisps);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final base = math.min(w, h);

    for (final wisp in wisps) {
      // Progreso de subida de esta voluta (0 = abajo, 1 = arriba)
      final p = ((t * wisp.speed) + wisp.phase) % 1.0;
      // Vaivén lateral: el humo cruza de un lado al otro mientras sube
      final drift = math.sin((p * 2.2 + wisp.phase) * math.pi * 2) * wisp.sway;
      final x = (wisp.startX + drift) * w;
      final y = h * (1.08 - p * 1.25);
      // Crece y se desvanece al subir; aparece suave abajo
      final fadeIn = (p / 0.15).clamp(0.0, 1.0);
      final fadeOut = (1.0 - p).clamp(0.0, 1.0);
      final alpha = 0.16 * fadeIn * fadeOut;
      if (alpha <= 0.003) continue;
      final r = base * (0.10 + p * 0.22) * wisp.size;
      final c = Offset(x, y);

      // Tres capas translúcidas simulan el borde difuminado del humo
      canvas.drawCircle(c, r, Paint()..color = wisp.color.withValues(alpha: alpha * 0.30));
      canvas.drawCircle(Offset(x + r * 0.18, y - r * 0.10), r * 0.70,
          Paint()..color = wisp.color.withValues(alpha: alpha * 0.45));
      canvas.drawCircle(Offset(x - r * 0.12, y + r * 0.08), r * 0.42,
          Paint()..color = wisp.color.withValues(alpha: alpha * 0.55));
    }
  }

  @override
  bool shouldRepaint(covariant _SmokePainter old) => old.t != t;
}
