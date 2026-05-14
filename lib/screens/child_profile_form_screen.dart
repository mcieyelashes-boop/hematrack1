import 'package:flutter/material.dart';

class ChildProfileFormScreen extends StatefulWidget {
  const ChildProfileFormScreen({super.key});

  @override
  State<ChildProfileFormScreen> createState() => _ChildProfileFormScreenState();
}

class _ChildProfileFormScreenState extends State<ChildProfileFormScreen> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Anak')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Anak'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _birthDate == null
                    ? 'Pilih tanggal lahir'
                    : 'Tanggal lahir: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil disimpan (stub)')),
                );
                Navigator.pop(context);
              },
              child: const Text('Simpan Profil'),
            )
          ],
        ),
      ),
    );
  }
}
