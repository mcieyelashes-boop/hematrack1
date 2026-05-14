import 'package:flutter/material.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = [
      {'week': 'Baseline', 'status': 'Awal'},
      {'week': 'Minggu 1', 'status': 'Stabil'},
      {'week': 'Minggu 2', 'status': 'Mengecil'},
      {'week': 'Minggu 3', 'status': 'Mengecil'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Timeline Monitoring')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockData.length,
        itemBuilder: (context, index) {
          final item = mockData[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(item['week']!),
              subtitle: Text('Status: ${item['status']}'),
            ),
          );
        },
      ),
    );
  }
}
