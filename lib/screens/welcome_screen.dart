import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/app_storage.dart';
import 'child_list_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _requesting = false;

  Future<void> _requestAndContinue() async {
    setState(() => _requesting = true);

    // Request camera permission
    final cameraStatus = await Permission.camera.request();
    // Request notification permission (Android 13+), tidak wajib
    await Permission.notification.request();

    if (!mounted) return;

    if (cameraStatus.isPermanentlyDenied) {
      // Buka settings jika user deny permanent
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Izin Kamera Diperlukan'),
          content: const Text(
              'HemaTrack memerlukan akses kamera untuk mengambil foto hemangioma. '
              'Silakan aktifkan izin kamera di pengaturan perangkat.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Nanti')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        ),
      );
    }

    await AppStorage.instance.setBool('onboarding_done', true);
    if (!mounted) return;
    _goToMain();
  }

  void _goToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChildListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.10),
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.pinkAccent, width: 2),
                ),
                child: const Icon(Icons.favorite,
                    size: 52, color: Colors.pinkAccent),
              ),
              const SizedBox(height: 24),
              Text(
                'HemaTrack',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent),
              ),
              const SizedBox(height: 8),
              const Text(
                'Monitoring visual hemangioma anak\ndengan mudah dan terstruktur',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: size.height * 0.06),

              // Features
              _FeatureRow(
                icon: Icons.camera_alt,
                title: 'Foto Baseline & Follow-up',
                subtitle:
                    'Ambil foto dengan overlay transparan untuk posisi yang konsisten',
              ),
              const SizedBox(height: 16),
              _FeatureRow(
                icon: Icons.timeline,
                title: 'Pantau Perkembangan',
                subtitle:
                    'Grafik tren ukuran relatif per minggu',
              ),
              const SizedBox(height: 16),
              _FeatureRow(
                icon: Icons.picture_as_pdf,
                title: 'Laporan PDF',
                subtitle:
                    'Export laporan dengan foto untuk konsultasi dokter',
              ),
              const SizedBox(height: 16),
              _FeatureRow(
                icon: Icons.lock_outline,
                title: 'Privasi Terjaga',
                subtitle:
                    'Semua data tersimpan lokal, tidak ada yang dikirim ke server',
              ),

              const Spacer(),

              // Permission note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.camera_alt_outlined,
                        color: Colors.blue, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aplikasi memerlukan izin kamera untuk mengambil foto hemangioma.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _requesting ? null : _requestAndContinue,
                  child: _requesting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Mulai Sekarang',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.pinkAccent, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
