import 'package:flutter/material.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Preview')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Export PDF'),
        ),
      ),
    );
  }
}
