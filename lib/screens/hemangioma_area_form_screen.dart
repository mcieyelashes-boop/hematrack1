import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/hemangioma_area.dart';
import '../services/hemangioma_repository.dart';

class HemangiomaAreaFormScreen extends StatefulWidget {
  final String childId;

  /// Jika diisi, screen berjalan dalam mode edit.
  final HemangiomaArea? editArea;

  const HemangiomaAreaFormScreen({
    super.key,
    required this.childId,
    this.editArea,
  });

  @override
  State<HemangiomaAreaFormScreen> createState() =>
      _HemangiomaAreaFormScreenState();
}

class _HemangiomaAreaFormScreenState
    extends State<HemangiomaAreaFormScreen> {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  bool get _isEdit => widget.editArea != null;

  static const _quickLocations = [
    'Kepala',
    'Wajah',
    'Leher',
    'Dada',
    'Perut',
    'Punggung',
    'Lengan kanan',
    'Lengan kiri',
    'Kaki kanan',
    'Kaki kiri',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _locationController.text = widget.editArea!.bodyLocation;
      _notesController.text = widget.editArea!.notes;
    }
  }

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

    if (_isEdit) {
      final old = widget.editArea!;
      final updated = HemangiomaArea(
        id: old.id,
        childId: old.childId,
        bodyLocation: location,
        baselinePhotoPath: old.baselinePhotoPath,
        baselineDate: old.baselineDate,
        baselineAreaValue: old.baselineAreaValue,
        notes: _notesController.text.trim(),
      );
      await HemangiomaRepository.instance.updateArea(updated);
    } else {
      final area = HemangiomaArea(
        id: const Uuid().v4(),
        childId: widget.childId,
        bodyLocation: location,
        baselinePhotoPath: '',
        baselineDate: DateTime.now(),
        notes: _notesController.text.trim(),
      );
      await HemangiomaRepository.instance.addArea(area);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _isEdit ? 'Edit Area Hemangioma' : 'Area Hemangioma')),
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
                      label: Text(loc,
                          style: const TextStyle(fontSize: 12)),
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
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEdit ? 'Simpan Perubahan' : 'Simpan Area'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
