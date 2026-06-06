import 'package:flutter/material.dart';

import '../models/child.dart';
import '../models/hemangioma_area.dart';
import '../services/hemangioma_repository.dart';
import '../services/reminder_service.dart';
import 'camera_baseline_screen.dart';
import 'camera_followup_screen.dart';
import 'comparison_screen.dart';
import 'hemangioma_area_form_screen.dart';
import 'report_preview_screen.dart';
import 'timeline_screen.dart';

class ChildDetailScreen extends StatefulWidget {
  final Child child;
  const ChildDetailScreen({super.key, required this.child});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  List<HemangiomaArea> _areas = [];
  bool _reminderActive = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkReminder();
  }

  void _load() {
    setState(() {
      _areas =
          HemangiomaRepository.instance.getAreasForChild(widget.child.id);
    });
  }

  Future<void> _checkReminder() async {
    final active = await ReminderService.instance.isScheduled();
    if (mounted) setState(() => _reminderActive = active);
  }

  Future<void> _toggleReminder() async {
    if (_reminderActive) {
      await ReminderService.instance.cancelReminder();
      setState(() => _reminderActive = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengingat mingguan dimatikan')),
        );
      }
    } else {
      final granted =
          await ReminderService.instance.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Izin notifikasi diperlukan untuk pengingat')),
          );
        }
        return;
      }
      await ReminderService.instance
          .scheduleWeeklyReminder(widget.child.name);
      setState(() => _reminderActive = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pengingat mingguan diaktifkan')),
        );
      }
    }
  }

  Future<void> _openAddArea() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            HemangiomaAreaFormScreen(childId: widget.child.id),
      ),
    );
    _load();
  }

  Future<void> _deleteArea(HemangiomaArea area) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Area'),
        content: Text(
            'Hapus area "${area.bodyLocation}" beserta semua fotonya?'),
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
    );
    if (ok == true) {
      await HemangiomaRepository.instance.deleteArea(area.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    return Scaffold(
      appBar: AppBar(
        title: Text(child.name),
        actions: [
          IconButton(
            icon: Icon(
              _reminderActive
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: _reminderActive ? Colors.pinkAccent : null,
            ),
            tooltip: _reminderActive
                ? 'Matikan pengingat mingguan'
                : 'Aktifkan pengingat mingguan',
            onPressed: _toggleReminder,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ChildInfoCard(child: child),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text('Area Hemangioma',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (_areas.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Laporan'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportPreviewScreen(
                        child: child,
                        areas: _areas,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_areas.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    'Belum ada area hemangioma. Tap + untuk menambah.'),
              ),
            )
          else
            ..._areas.map(
              (area) => _AreaCard(
                area: area,
                onBaseline: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CameraBaselineScreen(areaId: area.id),
                    ),
                  );
                  _load();
                },
                onFollowUp: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CameraFollowUpScreen(areaId: area.id),
                    ),
                  );
                  _load();
                },
                onTimeline: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimelineScreen(areaId: area.id),
                  ),
                ),
                onComparison: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComparisonScreen(areaId: area.id),
                  ),
                ),
                onDelete: () => _deleteArea(area),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddArea,
        tooltip: 'Tambah Area',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ChildInfoCard extends StatelessWidget {
  final Child child;
  const _ChildInfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int months = (now.year - child.birthDate.year) * 12 +
        now.month -
        child.birthDate.month;
    if (now.day < child.birthDate.day) months--;
    final ageStr = months < 12
        ? '$months bulan'
        : '${months ~/ 12} tahun ${months % 12} bulan';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              child: Icon(Icons.child_care, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                    'Lahir: ${child.birthDate.day}/${child.birthDate.month}/${child.birthDate.year}'),
                Text('Usia: $ageStr'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  final HemangiomaArea area;
  final VoidCallback onBaseline;
  final VoidCallback onFollowUp;
  final VoidCallback onTimeline;
  final VoidCallback onComparison;
  final VoidCallback onDelete;

  const _AreaCard({
    required this.area,
    required this.onBaseline,
    required this.onFollowUp,
    required this.onTimeline,
    required this.onComparison,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasBaseline = area.baselinePhotoPath.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.pinkAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    area.bodyLocation,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: hasBaseline
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasBaseline ? 'Baseline ada' : 'Belum ada baseline',
                    style: TextStyle(
                      fontSize: 11,
                      color: hasBaseline
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Hapus area',
                ),
              ],
            ),
            if (area.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(area.notes,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _Chip(
                  icon: Icons.camera_alt,
                  label:
                      hasBaseline ? 'Ganti Baseline' : 'Ambil Baseline',
                  onTap: onBaseline,
                ),
                if (hasBaseline) ...[
                  _Chip(
                      icon: Icons.photo_camera,
                      label: 'Follow-up',
                      onTap: onFollowUp),
                  _Chip(
                      icon: Icons.timeline,
                      label: 'Timeline',
                      onTap: onTimeline),
                  _Chip(
                      icon: Icons.compare,
                      label: 'Bandingkan',
                      onTap: onComparison),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}
