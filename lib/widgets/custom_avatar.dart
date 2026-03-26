import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final Color borderColor;

  const CustomAvatar({
    super.key,
    required this.photoUrl,
    this.radius = 25.0,
    this.borderColor = const Color(0xFF00E676),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.black,
        backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
            ? NetworkImage("$photoUrl?t=${DateTime.now().millisecondsSinceEpoch}")
            : null,
        child: (photoUrl == null || photoUrl!.isEmpty)
            ? Icon(Icons.person, size: radius * 1.1, color: Colors.white)
            : null,
      ),
    );
  }
}