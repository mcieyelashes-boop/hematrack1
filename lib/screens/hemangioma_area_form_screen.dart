import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/hemangioma_area.dart';
import '../services/hemangioma_repository.dart';

class HemangiomaAreaFormScreen extends StatefulWidget {
  final String childId;
  const HemangiomaAreaFormScreen({super.key, required this.childId});

  @override
  State<HemangiomaAreaFormScreen> createState() =>
      _HemangiomaAreaFormScreenState();
}

class _HemangiomaAreaFormScreenState
    extends State<HemangiomaAreaFormScreen> {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  static const _quickLocations = [
    'Kepala', 'Wajah', 'Leher', 'Dada', 'Perut',
    'Punggung', 'Lengan kanan', 'Lengan kiri', 'Kaki kanan', 'Kaki kiri',
    'Lainnya',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan lokasi tubuh')),
      );
      return;
    }
    setState(() => _saving = true);
    final area = HemangiomaArea(
      id: const Uuid().v4(),
      childId: widget.childId,
      bodyLocation: location,
      baselinePhotoPath: '',
      baselineDate: DateTime.now(),
      notes: _notesController.text.trim(),
    );
    await HemangiomaRepository.instance.addArea(area);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Area Hemangioma')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi tubuh',
                border: OutlineInputBorder(),
                hintText: 'mis. Kepala, Wajah...',
              ),
            ),
            const SizedBox(height: 8),
            const Text('Pilih cepat:',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _quickLocations
                  .map(
                    (loc) => ActionChip(
                      label: Text(loc, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          setState(() => _locationController.text = loc),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Area'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
