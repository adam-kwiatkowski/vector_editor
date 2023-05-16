import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_editor/graphics/utils.dart';

import '../drawing.dart';
import 'shape.dart';

class Circle extends Shape {
  int radius;
  bool full;
  double startAngle;
  double endAngle;
  double relativeStartAngle;

  Circle(ui.Offset offset, this.radius,
      {super.outlineColor,
      this.full = true,
      this.startAngle = 0,
      this.endAngle = 2 * pi,
      this.relativeStartAngle = 0})
      : super(offset);

  @override
  List<Handle> get handles => [
        Handle(
          offset + Offset(radius.toDouble(), 0),
          onMove: (offset) {
            radius += offset.dx.toInt();
            if (radius < 0) radius = 0;
          },
        ),
      ];

  @override
  String toString() {
    return 'Circle{offset: $offset, radius: $radius, color: $outlineColor, full: $full, startAngle: $startAngle, endAngle: $endAngle, relativeStartAngle: $relativeStartAngle}';
  }

  @override
  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = true}) {
    if (antiAlias) {
      wuCircle(pixels, size);
    } else {
      midpointCircle(pixels, size);
    }
  }

  void midpointCircle(Uint8List pixels, ui.Size size) {
    int dE = 3;
    int dSE = 5 - 2 * radius;
    int d = 1 - radius;
    int x = 0;
    int y = radius;

    while (y >= x) {
      _drawCircle(pixels, size, x, y);
      if (d < 0) {
        d += dE;
        dE += 2;
        dSE += 2;
      } else {
        d += dSE;
        dE += 2;
        dSE += 4;
        y--;
      }
      x++;
    }
  }

  @override
  bool contains(ui.Offset offset) {
    return (this.offset - offset).distance < radius;
  }

  void _drawCircle(Uint8List pixels, Size size, int x, int y) {
    _drawPixel(pixels, size, x, y);
    _drawPixel(pixels, size, x, -y);
    _drawPixel(pixels, size, -x, y);
    _drawPixel(pixels, size, -x, -y);
    _drawPixel(pixels, size, y, x);
    _drawPixel(pixels, size, y, -x);
    _drawPixel(pixels, size, -y, x);
    _drawPixel(pixels, size, -y, -x);
  }

  void _drawPixel(Uint8List pixels, Size size, int i, int j,
      {var alpha = 1.0}) {
    final x = offset.dx.toInt() + i;
    final y = offset.dy.toInt() + j;
    final width = size.width.toInt();
    final height = size.height.toInt();

    if (!full) {
      double angle = atan2(j.toDouble(), i.toDouble());
      if (startAngle < 0) startAngle += 2 * pi;
      if (startAngle > endAngle) endAngle += 2 * pi;

      if (angle < 0) angle += 2 * pi;
      if ((angle < startAngle || angle > endAngle) &&
          (angle + 2 * pi < startAngle || angle + 2 * pi > endAngle)) return;
    }

    if (x >= 0 && x < width && y >= 0 && y < height) {
      final index = (x + y * width) * 4;

      if (alpha != 1.0) {
        Color backgroundColor = getBackgroundColor(pixels, size, x, y);
        Color blendedColor =
            blendColors(outlineColor.withOpacity(alpha), backgroundColor);
        pixels[index] = blendedColor.red;
        pixels[index + 1] = blendedColor.green;
        pixels[index + 2] = blendedColor.blue;
        pixels[index + 3] = blendedColor.alpha;
        return;
      }

      pixels[index] = outlineColor.red;
      pixels[index + 1] = outlineColor.green;
      pixels[index + 2] = outlineColor.blue;
      pixels[index + 3] = outlineColor.alpha;
    }
  }

  void wuCircle(Uint8List pixels, Size size) {
    double x = radius.toDouble();
    double y = 0;
    _drawPixel(pixels, size, x.round(), y.round());
    _drawPixel(pixels, size, y.round(), x.round());
    _drawPixel(pixels, size, -x.round(), y.round());
    _drawPixel(pixels, size, -y.round(), -x.round());
    while (x > y) {
      y++;
      x = sqrt(radius * radius - y * y).ceilToDouble();
      var alpha = x - sqrt(radius * radius - y * y);
      _drawWuCircle(pixels, size, x, y, alpha);
    }
  }

  void _drawWuCircle(
      Uint8List pixels, ui.Size size, double x, double y, double alpha) {
    final dx = x.round();
    final dy = y.round();
    _drawPixel(pixels, size, dx, dy, alpha: (1 - alpha));
    _drawPixel(pixels, size, dx - 1, dy, alpha: alpha);
    _drawPixel(pixels, size, dy, dx, alpha: (1 - alpha));
    _drawPixel(pixels, size, dy, dx - 1, alpha: alpha);
    _drawPixel(pixels, size, -dx, dy, alpha: (1 - alpha));
    _drawPixel(pixels, size, -dx + 1, dy, alpha: alpha);
    _drawPixel(pixels, size, -dy, dx, alpha: (1 - alpha));
    _drawPixel(pixels, size, -dy, dx - 1, alpha: alpha);
    _drawPixel(pixels, size, dx, -dy, alpha: (1 - alpha));
    _drawPixel(pixels, size, dx - 1, -dy, alpha: alpha);
    _drawPixel(pixels, size, dy, -dx, alpha: (1 - alpha));
    _drawPixel(pixels, size, dy, -dx + 1, alpha: alpha);
    _drawPixel(pixels, size, -dx, -dy, alpha: (1 - alpha));
    _drawPixel(pixels, size, -dx + 1, -dy, alpha: alpha);
    _drawPixel(pixels, size, -dy, -dx, alpha: (1 - alpha));
    _drawPixel(pixels, size, -dy, -dx + 1, alpha: alpha);
  }

  static Shape? fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'circle') {
      return Circle(
        Offset(json['offset']['dx'], json['offset']['dy']),
        json['radius'],
        outlineColor: Color(json['color']),
        full: json['full'],
        startAngle: json['startAngle'],
        endAngle: json['endAngle'],
      );
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'circle',
      'offset': {'dx': offset.dx, 'dy': offset.dy},
      'radius': radius,
      'color': outlineColor.value,
      'full': full,
      'startAngle': startAngle,
      'endAngle': endAngle,
    };
  }
}
