import 'package:flutter/material.dart';

import 'privacy_policy_screen.dart';

class OnboardingDisclaimerScreen extends StatelessWidget {
  const OnboardingDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Penting')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.pinkAccent, width: 2),
                        ),
                        child: const Icon(Icons.health_and_safety,
                            size: 38, color: Colors.pinkAccent),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Disclaimer Medis',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.photo_camera,
                      title: 'Dokumentasi Visual Saja',
                      body:
                          'HemaTrack membantu Anda mendokumentasikan perubahan visual hemangioma secara terstruktur. '
                          'Ini bukan pengganti pemeriksaan dokter.',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.bar_chart,
                      title: 'Bukan Alat Diagnostik',
                      body:
                          'Ukuran relatif dan tren yang ditampilkan adalah estimasi visual, '
                          'bukan pengukuran klinis yang akurat. Selalu konsultasikan perubahan signifikan ke dokter spesialis.',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.lock_outline,
                      title: 'Data Tersimpan Lokal',
                      body:
                          'Semua foto dan data tersimpan hanya di perangkat Anda. '
                          'Tidak ada yang dikirim ke server. Privasi keluarga Anda terjaga.',
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PrivacyPolicyScreen()),
                        ),
                        child: const Text('Baca Kebijakan Privasi'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Saya Mengerti & Setuju',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _InfoCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
