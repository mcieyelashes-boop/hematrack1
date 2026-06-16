import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kebijakan Privasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan Privasi HemaTrack',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Terakhir diperbarui: 1 Juni 2025',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _Section(
              title: '1. Pendahuluan',
              body:
                  'HemaTrack ("Aplikasi") adalah aplikasi monitoring visual hemangioma anak yang beroperasi sepenuhnya secara offline di perangkat Anda. '
                  'Kebijakan privasi ini menjelaskan bagaimana kami menangani informasi Anda.',
            ),
            _Section(
              title: '2. Data yang Dikumpulkan',
              body:
                  'HemaTrack menyimpan data berikut HANYA di perangkat Anda:\n\n'
                  '• Profil anak (nama, tanggal lahir)\n'
                  '• Foto hemangioma (baseline dan follow-up)\n'
                  '• Catatan area hemangioma\n'
                  '• Data tren ukuran relatif\n\n'
                  'Tidak ada data yang dikirim ke server kami atau pihak ketiga.',
            ),
            _Section(
              title: '3. Penyimpanan Data',
              body:
                  'Seluruh data disimpan secara lokal di direktori dokumen aplikasi pada perangkat Anda. '
                  'Data tidak tersinkronisasi ke cloud dan tidak dapat diakses oleh kami atau pihak lain.\n\n'
                  'Menghapus aplikasi akan menghapus semua data secara permanen. '
                  'Kami menyarankan untuk melakukan backup foto secara manual ke penyimpanan eksternal.',
            ),
            _Section(
              title: '4. Izin yang Diperlukan',
              body:
                  'Aplikasi memerlukan izin berikut:\n\n'
                  '• Kamera: Untuk mengambil foto baseline dan follow-up hemangioma\n'
                  '• Notifikasi: Untuk pengingat follow-up mingguan (opsional)\n\n'
                  'Izin kamera hanya aktif saat layar kamera terbuka.',
            ),
            _Section(
              title: '5. Disclaimer Medis',
              body:
                  'HemaTrack adalah alat bantu dokumentasi visual BUKAN alat diagnostik medis. '
                  'Informasi dalam aplikasi ini tidak menggantikan konsultasi dengan dokter spesialis. '
                  'Selalu konsultasikan kondisi anak Anda kepada dokter yang berwenang.',
            ),
            _Section(
              title: '6. Anak-anak',
              body:
                  'Aplikasi ini dirancang untuk digunakan oleh orang tua atau wali dalam memantau kondisi medis anak. '
                  'Orang tua/wali bertanggung jawab atas penggunaan aplikasi dan keamanan data anak.',
            ),
            _Section(
              title: '7. Perubahan Kebijakan',
              body:
                  'Kami dapat memperbarui kebijakan privasi ini sewaktu-waktu. '
                  'Perubahan akan diberitahukan melalui pembaruan aplikasi.',
            ),
            _Section(
              title: '8. Kontak',
              body:
                  'Pertanyaan tentang kebijakan privasi ini dapat dikirimkan ke:\n'
                  'hematrack.app@gmail.com',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink.shade100),
              ),
              child: const Text(
                '⚕ HemaTrack tidak menyimpan, mengirim, atau menjual data pribadi Anda '
                'kepada siapapun. Privasi keluarga Anda adalah prioritas kami.',
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body,
              style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
