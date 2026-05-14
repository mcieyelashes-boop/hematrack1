import 'package:flutter/material.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparison')),
      body: Column(
        children: const [
          Expanded(child: Center(child: Text('Before / After comparison slider'))),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Status: Relatif stabil'),
          )
        ],
      ),
    );
  }
}
