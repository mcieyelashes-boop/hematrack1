import 'package:flutter/material.dart';

import '../models/child.dart';
import '../services/child_repository.dart';
import '../services/hemangioma_repository.dart';
import 'child_detail_screen.dart';
import 'child_profile_form_screen.dart';
import 'onboarding_disclaimer_screen.dart';

class ChildListScreen extends StatefulWidget {
  const ChildListScreen({super.key});

  @override
  State<ChildListScreen> createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  List<Child> _children = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _children = ChildRepository.instance.getAll().toList());
  }

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChildProfileFormScreen()),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HemaTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Disclaimer Medis',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingDisclaimerScreen()),
            ),
          ),
        ],
      ),
      body: _children.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.child_care, size: 64, color: Colors.pinkAccent),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada profil anak.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap tombol + untuk menambah profil anak pertama.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final child = _children[index];
                return Dismissible(
                  key: ValueKey(child.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(child.name),
                  onDismissed: (_) async {
                    await HemangiomaRepository.instance
                        .deleteAllAreasForChild(child.id);
                    await ChildRepository.instance.deleteChild(child.id);
                    _load();
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    child: ListTile(
                      leading:
                          const CircleAvatar(child: Icon(Icons.child_care)),
                      title: Text(child.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(_ageString(child.birthDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ChildDetailScreen(child: child)),
                        );
                        _load();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        tooltip: 'Tambah Anak',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _confirmDelete(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Profil Anak'),
            content: Text(
                'Hapus "$name" beserta semua area dan foto? Tindakan ini tidak dapat dibatalkan.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _ageString(DateTime birthDate) {
    final now = DateTime.now();
    int months =
        (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) months--;
    if (months < 1) return 'Kurang dari 1 bulan';
    if (months < 12) return '$months bulan';
    return '${months ~/ 12} tahun ${months % 12} bulan';
  }
}
