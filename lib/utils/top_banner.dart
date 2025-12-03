import 'package:flutter/material.dart';

void showTopBanner(BuildContext context, String msg, {bool error = false}) {
  OverlayEntry entry = OverlayEntry(
    builder: (_) => Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: error ? Colors.red.shade700 : Colors.green.shade700,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
          child: Text(
            msg,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(entry);

  Future.delayed(const Duration(seconds: 2)).then((_) {
    entry.remove();
  });
}