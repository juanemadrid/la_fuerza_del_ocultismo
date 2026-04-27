import 'package:flutter/material.dart';
import 'dart:math' as math;

class OccultLogo extends StatelessWidget {
  const OccultLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: OccultLogoPainter(),
      ),
    );
  }
}

class OccultLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Pintura para el círculo exterior
    final circlePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Círculo exterior
    canvas.drawCircle(center, radius - 10, circlePaint);

    // Marcas alrededor del círculo (como runas)
    final markPaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * math.pi / 180;
      final startX = center.dx + (radius - 15) * math.cos(angle);
      final startY = center.dy + (radius - 15) * math.sin(angle);
      final endX = center.dx + (radius - 5) * math.cos(angle);
      final endY = center.dy + (radius - 5) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), markPaint);
    }

    // Triángulo principal
    final trianglePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final triangleSize = radius * 0.7;
    final trianglePath = Path();
    
    // Triángulo apuntando hacia arriba
    trianglePath.moveTo(center.dx, center.dy - triangleSize);
    trianglePath.lineTo(
      center.dx - triangleSize * math.cos(math.pi / 6),
      center.dy + triangleSize * math.sin(math.pi / 6),
    );
    trianglePath.lineTo(
      center.dx + triangleSize * math.cos(math.pi / 6),
      center.dy + triangleSize * math.sin(math.pi / 6),
    );
    trianglePath.close();
    canvas.drawPath(trianglePath, trianglePaint);

    // Triángulos internos (efecto de capas)
    for (int i = 1; i <= 2; i++) {
      final innerSize = triangleSize - (i * 15);
      final innerPath = Path();
      innerPath.moveTo(center.dx, center.dy - innerSize);
      innerPath.lineTo(
        center.dx - innerSize * math.cos(math.pi / 6),
        center.dy + innerSize * math.sin(math.pi / 6),
      );
      innerPath.lineTo(
        center.dx + innerSize * math.cos(math.pi / 6),
        center.dy + innerSize * math.sin(math.pi / 6),
      );
      innerPath.close();
      
      final innerPaint = Paint()
        ..color = const Color(0xFFD32F2F).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawPath(innerPath, innerPaint);
    }

    // Símbolos místicos en el centro
    final symbolPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Círculo central superior
    canvas.drawCircle(Offset(center.dx, center.dy - 20), 4, symbolPaint);
    
    // Círculo central
    canvas.drawCircle(center, 5, Paint()..color = const Color(0xFFB71C1C));
    
    // Pequeños círculos decorativos
    canvas.drawCircle(Offset(center.dx - 15, center.dy + 10), 3, symbolPaint);
    canvas.drawCircle(Offset(center.dx + 15, center.dy + 10), 3, symbolPaint);

    // Línea horizontal en la base del triángulo
    final basePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawLine(
      Offset(center.dx - triangleSize * 0.6, center.dy + triangleSize * 0.4),
      Offset(center.dx + triangleSize * 0.6, center.dy + triangleSize * 0.4),
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
