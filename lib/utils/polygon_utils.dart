double calculatePolygonArea(List<Point<double>> points) {
  if (points.length < 3) return 0;
  double area = 0;
  for (int i = 0; i < points.length; i++) {
    final j = (i + 1) % points.length;
    area += points[i].x * points[j].y;
    area -= points[j].x * points[i].y;
  }
  return area.abs() / 2.0;
}

class Point<T extends num> {
  final T x;
  final T y;
  Point(this.x, this.y);
}
