import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../models/child.dart';
import '../models/hemangioma_area.dart';
import '../services/hemangioma_repository.dart';
import '../services/report_service.dart';

class ReportPreviewScreen extends StatefulWidget {
  final Child child;
  final List<HemangiomaArea> areas;

  const ReportPreviewScreen({
    super.key,
    required this.child,
    required this.areas,
  });

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final repo = HemangiomaRepository.instance;
      final followUpsMap = {
        for (final area in widget.areas)
          area.id: repo.getFollowUpsForArea(area.id),
      };
      final bytes = await ReportService.instance.generatePdf(
        child: widget.child,
        areas: widget.areas,
        followUpsMap: followUpsMap,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'hematrack_${widget.child.name.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF: $e')),
        );
      }
    }
    if (mounted) setState(() => _exporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final repo = HemangiomaRepository.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Monitoring')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReportHeader(child: widget.child, fmt: fmt),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...widget.areas.map((area) {
              final followUps = repo.getFollowUpsForArea(area.id);
              return _AreaReport(
                  area: area, followUpCount: followUps.length, fmt: fmt);
            }),
            const SizedBox(height: 24),
            const _DisclaimerBox(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: _exporting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Export & Bagikan PDF'),
                onPressed: _exporting ? null : _exportPdf,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final Child child;
  final DateFormat fmt;
  const _ReportHeader({required this.child, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Laporan Monitoring Hemangioma',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Pasien: ${child.name}'),
            Text(
                'Tanggal lahir: ${fmt.format(child.birthDate)} (${child.ageString})'),
            Text('Tanggal laporan: ${fmt.format(now)}'),
          ],
        ),
      ),
    );
  }
}

class _AreaReport extends StatelessWidget {
  final HemangiomaArea area;
  final int followUpCount;
  final DateFormat fmt;
  const _AreaReport(
      {required this.area,
      required this.followUpCount,
      required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: Colors.pinkAccent, size: 18),
                const SizedBox(width: 6),
                Text(area.bodyLocation,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 6),
            _InfoRow('Baseline',
                area.baselinePhotoPath.isNotEmpty
                    ? fmt.format(area.baselineDate)
                    : 'Belum ada'),
            _InfoRow('Follow-up', '$followUpCount foto'),
            if (area.notes.isNotEmpty) _InfoRow('Catatan', area.notes),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text('$label:',
                style:
                    const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
              child:
                  Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _DisclaimerBox extends StatelessWidget {
  const _DisclaimerBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '⚠ Laporan ini hanya untuk dokumentasi visual. Bukan alat diagnosis medis. '
        'Konsultasikan ke dokter untuk evaluasi klinis.',
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
