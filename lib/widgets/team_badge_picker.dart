import 'dart:io';

import 'package:flutter/material.dart';

class TeamBadgePicker extends StatelessWidget {
  final String? badgeUrl;
  final VoidCallback onPick;

  const TeamBadgePicker({
    super.key,
    required this.badgeUrl,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: CircleAvatar(
        radius: 35,
        backgroundImage: badgeUrl != null
            ? (badgeUrl!.startsWith("http")
            ? NetworkImage("${badgeUrl!}?t=${DateTime.now().millisecondsSinceEpoch}")
            : FileImage(File(badgeUrl!)) as ImageProvider)
            : null,
        child: badgeUrl == null
            ? const Icon(Icons.shield, size: 24)
            : null,
      ),
    );
  }
}