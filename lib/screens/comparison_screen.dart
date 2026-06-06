import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/hemangioma_repository.dart';

class ComparisonScreen extends StatefulWidget {
  final String areaId;
  const ComparisonScreen({super.key, required this.areaId});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  int _selectedIdx = 0;

  @override
  Widget build(BuildContext context) {
    final repo = HemangiomaRepository.instance;
    final area = repo.findAreaById(widget.areaId);
    final followUps = repo.getFollowUpsForArea(widget.areaId);
    final fmt = DateFormat('dd/MM/yyyy');

    if (area == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Area tidak ditemukan')),
      );
    }

    final hasBaseline = area.baselinePhotoPath.isNotEmpty;
    final hasFollowUp = followUps.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text('${area.bodyLocation} — Perbandingan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!hasBaseline)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada baseline untuk area ini.'),
                ),
              )
            else ...[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PhotoColumn(
                        title: 'Baseline',
                        subtitle: fmt.format(area.baselineDate),
                        photoPath: area.baselinePhotoPath,
                        badgeColor: Colors.pinkAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: hasFollowUp
                          ? _PhotoColumn(
                              title: 'Follow-up ${_selectedIdx + 1}',
                              subtitle: fmt.format(
                                  followUps[_selectedIdx].date),
                              photoPath:
                                  followUps[_selectedIdx].photoPath,
                              badgeColor: Colors.blueAccent,
                            )
                          : const _EmptyColumn(
                              label: 'Belum ada\nfollow-up'),
                    ),
                  ],
                ),
              ),
              if (hasFollowUp && followUps.length > 1) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: followUps.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${i + 1}'),
                        selected: _selectedIdx == i,
                        onSelected: (_) =>
                            setState(() => _selectedIdx = i),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoColumn extends StatelessWidget {
  final String title;
  final String subtitle;
  final String photoPath;
  final Color badgeColor;

  const _PhotoColumn({
    required this.title,
    required this.subtitle,
    required this.photoPath,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final exists = File(photoPath).existsSync();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: exists
                ? Image.file(File(photoPath), fit: BoxFit.cover,
                    width: double.infinity)
                : Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _EmptyColumn extends StatelessWidget {
  final String label;
  const _EmptyColumn({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('Follow-up',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 36),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ),
          ),
        ),
      ],
    );
  }
}
