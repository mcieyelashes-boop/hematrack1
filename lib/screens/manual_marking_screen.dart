import 'package:flutter/material.dart';

class ManualMarkingScreen extends StatelessWidget {
  const ManualMarkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Marking')),
      body: const Center(
        child: Text('Canvas polygon/freehand marking area.'),
      ),
    );
  }
}
