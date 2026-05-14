import 'package:flutter/material.dart';

import 'camera_baseline_screen.dart';
import 'camera_followup_screen.dart';
import 'child_profile_form_screen.dart';
import 'comparison_screen.dart';
import 'onboarding_disclaimer_screen.dart';
import 'report_preview_screen.dart';
import 'timeline_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HemaTrack')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Monitoring visual hemangioma anak',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dokumentasi visual baseline dan follow-up mingguan. Bukan alat diagnosis medis.',
          ),
          const SizedBox(height: 24),
          _HomeButton(
            title: 'Disclaimer Medis',
            subtitle: 'Baca batasan penggunaan aplikasi',
            onTap: () => _open(context, const OnboardingDisclaimerScreen()),
          ),
          _HomeButton(
            title: 'Tambah Profil Anak',
            subtitle: 'Simpan nama, tanggal lahir, dan catatan awal',
            onTap: () => _open(context, const ChildProfileFormScreen()),
          ),
          _HomeButton(
            title: 'Ambil Baseline Photo',
            subtitle: 'Foto pertama sebagai acuan overlay',
            onTap: () => _open(context, const CameraBaselineScreen()),
          ),
          _HomeButton(
            title: 'Foto Mingguan Follow-up',
            subtitle: 'Gunakan ghost overlay dari baseline',
            onTap: () => _open(context, const CameraFollowUpScreen()),
          ),
          _HomeButton(
            title: 'Lihat Perbandingan',
            subtitle: 'Bandingkan area yang ditandai',
            onTap: () => _open(context, const ComparisonScreen()),
          ),
          _HomeButton(
            title: 'Timeline Monitoring',
            subtitle: 'Riwayat foto dan tren perubahan',
            onTap: () => _open(context, const TimelineScreen()),
          ),
          _HomeButton(
            title: 'Export Laporan',
            subtitle: 'Buat laporan PDF sederhana',
            onTap: () => _open(context, const ReportPreviewScreen()),
          ),
        ],
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
