import '../utils/polygon_utils.dart';

class MeasurementService {
  double areaFromPoints(List<Point<double>> points) {
    return calculatePolygonArea(points);
  }

  String classifyChange({required double baselineArea, required double currentArea}) {
    if (baselineArea <= 0) return 'Belum ada baseline';
    final change = (currentArea - baselineArea) / baselineArea;
    if (change > 0.10) return 'Membesar';
    if (change < -0.10) return 'Mengecil';
    return 'Relatif stabil';
  }

  double percentChange({required double baselineArea, required double currentArea}) {
    if (baselineArea <= 0) return 0;
    return ((currentArea - baselineArea) / baselineArea) * 100;
  }
}
