import 'dart:typed_data';
import 'dart:ui' as ui;

import '../drawing.dart';
import 'line.dart';
import 'shape.dart';

class Polygon extends Shape {
  final List<ui.Offset> points;
  bool closed;
  int thickness;

  Polygon(this.points, ui.Offset offset,
      {this.closed = false, this.thickness = 1, super.outlineColor})
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
      final line = Line(point1, point2, outlineColor: outlineColor, thickness: thickness);
      line.draw(pixels, size, antiAlias: antiAlias);
    }
    if (closed) {
      final point1 = points[points.length - 1];
      final point2 = points[0];
      final line = Line(point1, point2, outlineColor: outlineColor, thickness: thickness);
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
}
