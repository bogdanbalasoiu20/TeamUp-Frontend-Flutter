import 'package:flutter/material.dart';

class IdkPage extends StatefulWidget {
  const IdkPage({super.key});

  @override
  State<IdkPage> createState() => _IdkPageState();
}

class _IdkPageState extends State<IdkPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Something cool is coming 👀\n\nThis feature is still a mystery\nComing soon",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
