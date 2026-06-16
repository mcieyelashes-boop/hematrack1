import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Screen untuk menandai area hemangioma pada foto dengan polygon freehand.
/// Mengembalikan [double] estimasi luas relatif (dalam persen dari luas foto)
/// saat user tap "Konfirmasi".
class ManualMarkingScreen extends StatefulWidget {
  /// Path foto yang akan ditandai (baseline atau follow-up).
  final String photoPath;

  /// Label tampilan, mis. "Tandai Area Hemangioma"
  final String title;

  const ManualMarkingScreen({
    super.key,
    required this.photoPath,
    this.title = 'Tandai Area',
  });

  @override
  State<ManualMarkingScreen> createState() => _ManualMarkingScreenState();
}

class _ManualMarkingScreenState extends State<ManualMarkingScreen> {
  final List<Offset> _points = [];
  bool _closed = false;
  Size? _canvasSize;

  void _onTap(Offset local) {
    if (_closed) return;
    setState(() {
      // Jika dekat titik pertama (radius 20px) dan sudah ada ≥3 titik → tutup polygon
      if (_points.length >= 3) {
        final first = _points.first;
        final dist = (local - first).distance;
        if (dist < 24) {
          _closed = true;
          return;
        }
      }
      _points.add(local);
    });
  }

  void _reset() {
    setState(() {
      _points.clear();
      _closed = false;
    });
  }

  double _computeAreaFraction() {
    if (_points.length < 3 || _canvasSize == null) return 0;
    // Shoelace formula untuk luas polygon
    double area = 0;
    final n = _points.length;
    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      area += _points[i].dx * _points[j].dy;
      area -= _points[j].dx * _points[i].dy;
    }
    area = area.abs() / 2;
    final total = _canvasSize!.width * _canvasSize!.height;
    return total > 0 ? area / total : 0;
  }

  void _confirm() {
    final fraction = _computeAreaFraction();
    Navigator.pop(context, fraction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_points.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Ulangi',
              onPressed: _reset,
            ),
        ],
      ),
      body: Column(
        children: [
          // Instruction
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            color: Colors.pink.shade50,
            child: Text(
              _closed
                  ? 'Area ditandai. Konfirmasi atau ulangi.'
                  : _points.isEmpty
                      ? 'Tap pada foto untuk mulai menandai area hemangioma. '
                          'Tap dekat titik pertama untuk menutup.'
                      : 'Lanjutkan menandai titik. Tap dekat titik awal (○) untuk menutup.',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

          // Canvas
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _canvasSize = Size(
                    constraints.maxWidth, constraints.maxHeight);
                return GestureDetector(
                  onTapDown: (d) => _onTap(d.localPosition),
                  child: Stack(
                    children: [
                      // Foto
                      Positioned.fill(
                        child: Image.file(
                          File(widget.photoPath),
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Overlay polygon
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _PolygonPainter(
                            points: _points,
                            closed: _closed,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _points.isEmpty ? null : _reset,
                    icon: const Icon(Icons.clear),
                    label: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _closed ? _confirm : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Konfirmasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolygonPainter extends CustomPainter {
  final List<Offset> points;
  final bool closed;

  const _PolygonPainter({required this.points, required this.closed});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Fill saat polygon tertutup
    if (closed && points.length >= 3) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, linePaint);
    } else {
      // Garis sambungan antar titik
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], linePaint);
      }
      // Garis putus-putus ke titik pertama saat hampir tutup
      if (points.length >= 3) {
        final dashPaint = Paint()
          ..color = Colors.pinkAccent.withOpacity(0.5)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        _drawDashedLine(
            canvas, points.last, points.first, dashPaint);
      }
    }

    // Titik-titik
    for (int i = 0; i < points.length; i++) {
      final isFirst = i == 0;
      // Titik pertama: lebih besar dan border hijau sbg penanda "tutup di sini"
      final radius = isFirst ? 10.0 : 6.0;
      canvas.drawCircle(points[i], radius, dotPaint);
      canvas.drawCircle(
          points[i],
          radius,
          isFirst
              ? (Paint()
                ..color = Colors.green
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.5)
              : dotBorderPaint);
    }
  }

  void _drawDashedLine(
      Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLen = 6.0;
    const gapLen = 4.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final nx = dx / len;
    final ny = dy / len;
    double dist = 0;
    bool drawing = true;
    while (dist < len) {
      final segLen =
          drawing ? math.min(dashLen, len - dist) : math.min(gapLen, len - dist);
      if (drawing) {
        canvas.drawLine(
          Offset(p1.dx + nx * dist, p1.dy + ny * dist),
          Offset(p1.dx + nx * (dist + segLen), p1.dy + ny * (dist + segLen)),
          paint,
        );
      }
      dist += segLen;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_PolygonPainter old) =>
      old.points != points || old.closed != closed;
}
