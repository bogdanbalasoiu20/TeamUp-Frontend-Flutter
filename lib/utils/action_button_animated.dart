import 'package:flutter/material.dart';

class ActionButtonAnimated extends StatefulWidget {
  final List<Color> colors;
  final String text;
  final VoidCallback onTap;

  const ActionButtonAnimated({
    super.key,
    required this.colors,
    required this.text,
    required this.onTap,
  });

  @override
  State<ActionButtonAnimated> createState() => _ActionButtonAnimatedState();
}

class _ActionButtonAnimatedState extends State<ActionButtonAnimated>
    with SingleTickerProviderStateMixin {

  double scale = 1.0;
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => scale = 0.93);
      },
      onTapCancel: () {
        setState(() => scale = 1.0);
      },
      onTapUp: (_) async {
        setState(() => scale = 1.0);
        await Future.delayed(const Duration(milliseconds: 80));

        widget.onTap();
      },
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.colors.last.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}