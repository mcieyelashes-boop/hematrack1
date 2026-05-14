import 'package:flutter/material.dart';

class HemangiomaAreaFormScreen extends StatefulWidget {
  const HemangiomaAreaFormScreen({super.key});

  @override
  State<HemangiomaAreaFormScreen> createState() => _HemangiomaAreaFormScreenState();
}

class _HemangiomaAreaFormScreenState extends State<HemangiomaAreaFormScreen> {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Area Hemangioma')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Lokasi tubuh'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Catatan'),
              maxLines: 4,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Simpan Area'),
            )
          ],
        ),
      ),
    );
  }
}
