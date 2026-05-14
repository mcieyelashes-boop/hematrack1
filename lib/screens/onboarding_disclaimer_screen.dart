import 'package:flutter/material.dart';

class OnboardingDisclaimerScreen extends StatelessWidget {
  const OnboardingDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disclaimer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Aplikasi ini hanya membantu dokumentasi visual. Hasil perbandingan bukan diagnosis medis. Konsultasikan ke dokter bila ada perubahan signifikan.',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Saya Mengerti'),
            )
          ],
        ),
      ),
    );
  }
}
