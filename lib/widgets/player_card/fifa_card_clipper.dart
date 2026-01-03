import 'package:flutter/material.dart';

class FifaCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(size.width * 0.08, 0);
    path.lineTo(size.width * 0.92, 0);

    path.quadraticBezierTo(
      size.width,
      size.height * 0.08,
      size.width,
      size.height * 0.18,
    );

    path.lineTo(size.width, size.height * 0.88);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.88);

    path.lineTo(0, size.height * 0.18);
    path.quadraticBezierTo(
      0,
      size.height * 0.08,
      size.width * 0.08,
      0,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
