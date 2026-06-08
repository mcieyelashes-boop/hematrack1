import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/child.dart';
import '../services/child_repository.dart';

class ChildProfileFormScreen extends StatefulWidget {
  /// Jika diisi, screen berjalan dalam mode edit.
  final Child? editChild;

  const ChildProfileFormScreen({super.key, this.editChild});

  @override
  State<ChildProfileFormScreen> createState() =>
      _ChildProfileFormScreenState();
}

class _ChildProfileFormScreenState extends State<ChildProfileFormScreen> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  bool _saving = false;

  bool get _isEdit => widget.editChild != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.editChild!.name;
      _birthDate = widget.editChild!.birthDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama anak tidak boleh kosong')),
      );
      return;
    }
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal lahir terlebih dahulu')),
      );
      return;
    }
    setState(() => _saving = true);

    if (_isEdit) {
      // Pertahankan id dan createdAt yang lama
      final updated = Child(
        id: widget.editChild!.id,
        name: name,
        birthDate: _birthDate!,
        createdAt: widget.editChild!.createdAt,
      );
      await ChildRepository.instance.updateChild(updated);
      if (mounted) Navigator.pop(context, updated);
    } else {
      final child = Child(
        id: const Uuid().v4(),
        name: name,
        birthDate: _birthDate!,
        createdAt: DateTime.now(),
      );
      await ChildRepository.instance.addChild(child);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(_isEdit ? 'Edit Profil Anak' : 'Profil Anak')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Anak',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _birthDate == null
                      ? 'Tap untuk memilih'
                      : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                  style: TextStyle(
                    color: _birthDate == null ? Colors.grey : null,
                  ),
                ),
              ),
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
                    : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
