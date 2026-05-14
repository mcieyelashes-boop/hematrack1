import 'package:flutter/material.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline Monitoring')),
      body: const Center(
        child: Text('Timeline follow-up photo akan tampil di sini.'),
      ),
    );
  }
}
