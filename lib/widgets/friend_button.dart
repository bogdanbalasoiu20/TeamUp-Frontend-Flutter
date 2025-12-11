import 'package:flutter/material.dart';

class FriendButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final List<Color> colors;
  final bool disabled;
  final IconData? icon;
  final EdgeInsets padding;

  const FriendButton({
    super.key,
    required this.text,
    required this.colors,
    required this.onTap,
    this.icon,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
  });

  @override
  State<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _animateTapDown() {
    if (widget.disabled) return;
    setState(() => _scale = 0.94);
  }

  void _animateTapUp() {
    if (widget.disabled) return;
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: widget.disabled ? 0.55 : 1,
      child: GestureDetector(
        onTapDown: (_) => _animateTapDown(),
        onTapUp: (_) => _animateTapUp(),
        onTapCancel: () => _animateTapUp(),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: InkWell(
            onTap: widget.disabled ? null : widget.onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.disabled
                      ? [Colors.grey.shade600, Colors.grey.shade500]
                      : widget.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors.last.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
