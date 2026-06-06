import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/follow_up_photo.dart';
import '../models/hemangioma_area.dart';
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
                if (followUps.isNotEmpty) ...[
                  const Text('Tren Ukuran',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _TrendChart(followUps: followUps),
                  const SizedBox(height: 16),
                ],
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
                        label:
                            'Minggu ${e.key + 1} — ${fmt.format(e.value.date)}',
                        photoPath: e.value.photoPath,
                        badge: 'Follow-up ${e.key + 1}',
                        badgeColor: Colors.blueAccent,
                        sizeLabel: _sizeLabel(e.value.areaRelativeValue),
                        sizeLabelColor:
                            _sizeColor(e.value.areaRelativeValue),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _sizeLabel(double v) {
    if (v < 0.6) return 'Sangat mengecil';
    if (v < 0.9) return 'Mengecil';
    if (v <= 1.1) return 'Stabil';
    if (v <= 1.4) return 'Membesar';
    return 'Sangat membesar';
  }

  Color _sizeColor(double v) {
    if (v < 0.9) return Colors.green;
    if (v <= 1.1) return Colors.blue;
    return Colors.red;
  }
}

class _TrendChart extends StatelessWidget {
  final List<FollowUpPhoto> followUps;
  const _TrendChart({required this.followUps});

  @override
  Widget build(BuildContext context) {
    final spots = followUps.asMap().entries
        .map((e) => FlSpot(
              (e.key + 1).toDouble(),
              e.value.areaRelativeValue,
            ))
        .toList();

    final maxX = (followUps.length + 0.5).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: maxX,
              minY: 0.3,
              maxY: 1.8,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 0.3,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: 0.3,
                    getTitlesWidget: (v, _) => Text(
                      '${(v * 100).toInt()}%',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx == 0 || idx > followUps.length) {
                        return const SizedBox.shrink();
                      }
                      return Text('W$idx',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                // Baseline reference (y = 1.0, dashed grey)
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 1.0),
                    FlSpot(maxX, 1.0),
                  ],
                  isCurved: false,
                  color: Colors.grey.withOpacity(0.5),
                  barWidth: 1,
                  dotData: const FlDotData(show: false),
                  dashArray: [6, 4],
                ),
                // Actual follow-up data
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: Colors.pinkAccent,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: Colors.pinkAccent,
                      strokeWidth: 1.5,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.pinkAccent.withOpacity(0.08),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
}

class _PhotoCard extends StatelessWidget {
  final String label;
  final String photoPath;
  final String badge;
  final Color badgeColor;
  final String? sizeLabel;
  final Color? sizeLabelColor;

  const _PhotoCard({
    required this.label,
    required this.photoPath,
    required this.badge,
    required this.badgeColor,
    this.sizeLabel,
    this.sizeLabelColor,
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
                          child: Icon(Icons.image_not_supported,
                              size: 48),
                        ),
                      ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(badge,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ),
              ),
              if (sizeLabel != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (sizeLabelColor ?? Colors.grey)
                          .withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(sizeLabel!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
