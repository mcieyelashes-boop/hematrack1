import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/child.dart';
import '../models/follow_up_photo.dart';
import '../models/hemangioma_area.dart';

class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  Future<Uint8List> generatePdf({
    required Child child,
    required List<HemangiomaArea> areas,
    required Map<String, List<FollowUpPhoto>> followUpsMap,
  }) async {
    final doc = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    int months = (now.year - child.birthDate.year) * 12 +
        now.month -
        child.birthDate.month;
    if (now.day < child.birthDate.day) months--;
    final ageStr = months < 12
        ? '$months bulan'
        : '${months ~/ 12} tahun ${months % 12} bulan';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.pink100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Laporan Monitoring Hemangioma',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Pasien     : ${child.name}'),
                pw.Text(
                    'Tanggal lahir : ${fmt.format(child.birthDate)} ($ageStr)'),
                pw.Text('Tanggal laporan : ${fmt.format(now)}'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Ringkasan Area Hemangioma',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          // Area table
          pw.TableHelper.fromTextArray(
            headers: ['Lokasi', 'Baseline', 'Follow-up', 'Catatan'],
            data: areas.map((area) {
              final fus = followUpsMap[area.id] ?? [];
              return [
                area.bodyLocation,
                area.baselinePhotoPath.isNotEmpty
                    ? fmt.format(area.baselineDate)
                    : '-',
                '${fus.length} foto',
                area.notes.isEmpty ? '-' : area.notes,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.pink200),
            cellHeight: 28,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.centerLeft,
            },
          ),
          pw.SizedBox(height: 16),
          // Per-area detail
          ...areas.map((area) {
            final fus = followUpsMap[area.id] ?? [];
            if (fus.isEmpty) return pw.SizedBox();
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Detail: ${area.bodyLocation}',
                  style:
                      pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.TableHelper.fromTextArray(
                  headers: ['#', 'Tanggal', 'Ukuran relatif', 'Tren'],
                  data: fus.asMap().entries.map((e) {
                    final idx = e.key;
                    final fu = e.value;
                    final prev = idx == 0
                        ? 1.0
                        : fus[idx - 1].areaRelativeValue;
                    final trend = fu.areaRelativeValue < prev - 0.05
                        ? '↓ Mengecil'
                        : fu.areaRelativeValue > prev + 0.05
                            ? '↑ Membesar'
                            : '→ Stabil';
                    return [
                      '${idx + 1}',
                      fmt.format(fu.date),
                      '${(fu.areaRelativeValue * 100).toStringAsFixed(0)}%',
                      trend,
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey200),
                  cellHeight: 24,
                ),
                pw.SizedBox(height: 12),
              ],
            );
          }),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.orange),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              '⚠ PERINGATAN: Laporan ini hanya untuk dokumentasi visual. Bukan alat diagnosis medis. '
              'Konsultasikan ke dokter untuk evaluasi klinis.',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }
}
