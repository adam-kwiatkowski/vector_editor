import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:vector_editor/graphics/shapes/shape_visitor.dart';

import '../drawing.dart';
import 'line.dart';
import 'shape.dart';

class Polygon extends Shape {
  final List<ui.Offset> points;
  bool closed;
  int thickness;
  ui.Color? fillColor;

  Polygon(this.points, ui.Offset offset,
      {this.closed = false,
      this.thickness = 1,
      this.fillColor,
      super.outlineColor})
      : super(offset);

  @override
  List<Handle> get handles {
    final handles = <Handle>[];
    for (var i = 0; i < points.length; i++) {
      handles.add(Handle(points[i], onMove: (offset) {
        points[i] += offset;
      }));
    }
    return handles;
  }

  @override
  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = false}) {
    for (var i = 0; i < points.length - 1; i++) {
      final point1 = points[i];
      final point2 = points[i + 1];
      final line = Line(point1, point2,
          outlineColor: outlineColor, thickness: thickness);
      line.draw(pixels, size, antiAlias: antiAlias);
    }
    if (closed) {
      final point1 = points[points.length - 1];
      final point2 = points[0];
      final line = Line(point1, point2,
          outlineColor: outlineColor, thickness: thickness);
      line.draw(pixels, size, antiAlias: antiAlias);

      if (fillColor != null) {
        scanlineFill(pixels, size, fillColor!);
      }
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

  void removePointAt(ui.Offset offset) {
    for (var i = 0; i < points.length; i++) {
      if ((points[i] - offset).distance < 10) {
        points.removeAt(i);
        break;
      }
    }
  }

  static Shape? fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'polygon') {
      final points = <ui.Offset>[];
      for (var i = 0; i < json['points'].length; i++) {
        final point = json['points'][i];
        points.add(ui.Offset(point['x'], point['y']));
      }
      return Polygon(points, ui.Offset.zero,
          closed: json['closed'],
          thickness: json['thickness'],
          outlineColor: ui.Color(json['color']));
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final points = <Map<String, double>>[];
    for (var i = 0; i < this.points.length; i++) {
      final point = this.points[i];
      points.add({'x': point.dx, 'y': point.dy});
    }
    return {
      'type': 'polygon',
      'points': points,
      'closed': closed,
      'thickness': thickness,
      'color': outlineColor.value,
    };
  }

  @override
  void accept(ShapeVisitor visitor) {
    visitor.visitPolygon(this);
  }

  void drawPixel(
      Uint8List pixels, ui.Size size, ui.Offset pos, ui.Color color) {
    final x = pos.dx.toInt();
    final y = pos.dy.toInt();
    if (x < 0 || x >= size.width || y < 0 || y >= size.height) {
      return;
    }
    final index = ((x + y * size.width) * 4).round();
    pixels[index] = color.red;
    pixels[index + 1] = color.green;
    pixels[index + 2] = color.blue;
    pixels[index + 3] = color.alpha;
  }

  void scanlineFill(Uint8List pixels, ui.Size size, ui.Color color) {
    List<int> sortedIndices = List<int>.generate(points.length, (i) => i);
    sortedIndices.sort((a, b) {
      int yCompare = points[a].dy.compareTo(points[b].dy);
      return yCompare == 0 ? points[a].dx.compareTo(points[b].dx) : yCompare;
    });

    List<EdgeEntry> aet = [];

    for (int y = 0; y < size.height.toInt(); y++) {
      while (sortedIndices.isNotEmpty &&
          points[sortedIndices.first].dy.toInt() == y) {
        int currentIndex = sortedIndices.removeAt(0);
        int prevIndex = (currentIndex - 1 + points.length) % points.length;
        int nextIndex = (currentIndex + 1) % points.length;

        ui.Offset currentPoint = points[currentIndex];
        if (points[nextIndex].dy > currentPoint.dy) {
          aet.add(createEdge(points[currentIndex], points[nextIndex]));
        }
        if (points[prevIndex].dy > currentPoint.dy) {
          aet.add(createEdge(points[currentIndex], points[prevIndex]));
        }
      }

      aet.removeWhere((edge) => edge.yMax.toInt() == y);
      for (var edge in aet) {
        edge.x += edge.dx;
      }

      aet.sort((a, b) => (a.x).compareTo(b.x));

      for (int i = 0; i < aet.length; i += 2) {
        int startX = aet[i].x.toInt();
        int endX = aet[i + 1].x.toInt();
        for (int x = startX; x <= endX; x++) {
          drawPixel(pixels, size, ui.Offset(x.toDouble(), y.toDouble()), color);
        }
      }
    }
  }

  EdgeEntry createEdge(ui.Offset start, ui.Offset end) {
    double dx = (end.dx - start.dx) / (end.dy - start.dy);
    return EdgeEntry(
      x: start.dx,
      yMax: end.dy,
      dx: dx,
    );
  }
}

class EdgeEntry {
  double x;
  double yMax;
  double dx;

  EdgeEntry({
    required this.x,
    required this.yMax,
    required this.dx,
  });
}
