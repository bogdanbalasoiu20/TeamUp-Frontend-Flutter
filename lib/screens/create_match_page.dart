import 'package:flutter/material.dart';
import '../widgets/mini_map_widget.dart';

class CreateMatchPage extends StatelessWidget {
  const CreateMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Match")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            MiniMapWidget(),
          ],
        ),
      ),
    );
  }
}
