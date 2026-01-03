import 'package:flutter/material.dart';

class FifaCrystalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.15);

    void triangle(Offset a, Offset b, Offset c) {
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..close();
      canvas.drawPath(path, paint);
    }

    triangle(
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.45, size.height * 0.05),
      Offset(size.width * 0.55, size.height * 0.3),
    );

    triangle(
      Offset(size.width * 0.4, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.15),
      Offset(size.width * 0.7, size.height * 0.45),
    );

    triangle(
      Offset(size.width * 0.2, size.height * 0.45),
      Offset(size.width * 0.55, size.height * 0.35),
      Offset(size.width * 0.6, size.height * 0.65),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
