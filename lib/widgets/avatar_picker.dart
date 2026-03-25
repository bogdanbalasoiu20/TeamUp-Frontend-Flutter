import 'package:flutter/material.dart';

class AvatarPicker extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onPick;

  const AvatarPicker({
    super.key,
    required this.imageUrl,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: imageUrl != null
            ? NetworkImage("${imageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}")
            : null,
        child: imageUrl == null
            ? const Icon(Icons.add_a_photo, size: 30)
            : null,
      ),
    );
  }
}