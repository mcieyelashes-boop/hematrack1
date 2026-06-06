import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/hemangioma_repository.dart';

class TimelineScreen extends StatelessWidget {
  final String areaId;
  const TimelineScreen({super.key, required this.areaId});

  @override
  Widget build(BuildContext context) {
    final repo = HemangiomaRepository.instance;
    final area = repo.findAreaById(areaId);
    final followUps = repo.getFollowUpsForArea(areaId);
    final fmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: Text(area?.bodyLocation ?? 'Timeline')),
      body: area == null
          ? const Center(child: Text('Area tidak ditemukan'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (area.baselinePhotoPath.isNotEmpty) ...[
                  const _SectionHeader(label: 'Baseline'),
                  const SizedBox(height: 8),
                  _PhotoCard(
                    label: 'Baseline — ${fmt.format(area.baselineDate)}',
                    photoPath: area.baselinePhotoPath,
                    badge: 'Baseline',
                    badgeColor: Colors.pinkAccent,
                  ),
                  const SizedBox(height: 16),
                ],
                const _SectionHeader(label: 'Follow-up'),
                const SizedBox(height: 8),
                if (followUps.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Belum ada foto follow-up.'),
                    ),
                  )
                else
                  ...followUps.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PhotoCard(
                        label: 'Minggu ${e.key + 1} — ${fmt.format(e.value.date)}',
                        photoPath: e.value.photoPath,
                        badge: 'Follow-up ${e.key + 1}',
                        badgeColor: Colors.blueAccent,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
}

class _PhotoCard extends StatelessWidget {
  final String label;
  final String photoPath;
  final String badge;
  final Color badgeColor;

  const _PhotoCard({
    required this.label,
    required this.photoPath,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final fileExists = File(photoPath).existsSync();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: fileExists
                    ? Image.file(File(photoPath), fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        ),
                      ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(badge,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
