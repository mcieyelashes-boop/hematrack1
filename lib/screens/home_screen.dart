import 'package:flutter/material.dart';

import 'onboarding_disclaimer_screen.dart';
import 'timeline_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HemaTrack')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Monitoring visual hemangioma anak',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OnboardingDisclaimerScreen(),
                  ),
                );
              },
              child: const Text('Disclaimer'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Tambah Profil Anak'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Ambil Baseline Photo'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Foto Mingguan Follow-up'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TimelineScreen(),
                  ),
                );
              },
              child: const Text('Timeline Monitoring'),
            ),
          ],
        ),
      ),
    );
  }
}
