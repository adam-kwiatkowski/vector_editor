import 'dart:typed_data';
import 'dart:ui' as ui;

import 'drawing.dart';
import 'line.dart';

class Polygon extends Shape {
  final List<ui.Offset> points;
  bool closed = false;

  Polygon(this.points, ui.Offset offset) : super(offset);

  @override
  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = false}) {
    for (var i = 0; i < points.length - 1; i++) {
      final point1 = points[i];
      final point2 = points[i + 1];
      final line = Line(point1, point2, color: color);
      line.draw(pixels, size, antiAlias: antiAlias);
    }
    if (closed) {
      final point1 = points[points.length - 1];
      final point2 = points[0];
      final line = Line(point1, point2, color: color);
      line.draw(pixels, size, antiAlias: antiAlias);
    }
  }

  @override
  bool contains(ui.Offset offset) {
    var inside = false;
    for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
      final xi = points[i].dx;
      final yi = points[i].dy;
      final xj = points[j].dx;
      final yj = points[j].dy;
      final intersect = ((yi > offset.dy) != (yj > offset.dy)) &&
          (offset.dx < (xj - xi) * (offset.dy - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  @override
  void move(ui.Offset offset) {
    for (var i = 0; i < points.length; i++) {
      points[i] += offset;
    }
    this.offset += offset;
  }
}
