class ReportService {
  Future<String> exportPdfReport({
    required String childName,
    required String location,
  }) async {
    // TODO: implement real PDF generation using pdf package
    final summary = '''
HemaTrack Report
Nama Anak: $childName
Lokasi Hemangioma: $location
Disclaimer: Dokumentasi visual, bukan diagnosis medis.
''';

    return summary;
  }
}
