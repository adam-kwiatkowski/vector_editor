import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_editor/graphics/utils.dart';

import 'drawing.dart';

class Circle extends Shape {
  final int radius;

  Circle(ui.Offset offset, this.radius, {super.color}) : super(offset);

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
    if (x >= 0 && x < width && y >= 0 && y < height) {
      final index = (x + y * width) * 4;

      if (alpha != 1.0) {
        Color backgroundColor = getBackgroundColor(pixels, size, x, y);
        Color blendedColor =
            blendColors(color.withOpacity(alpha), backgroundColor);
        pixels[index] = blendedColor.red;
        pixels[index + 1] = blendedColor.green;
        pixels[index + 2] = blendedColor.blue;
        pixels[index + 3] = blendedColor.alpha;
        return;
      }

      pixels[index] = color.red;
      pixels[index + 1] = color.green;
      pixels[index + 2] = color.blue;
      pixels[index + 3] = color.alpha;
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
    _drawPixel(pixels, size, x.round(), y.round(), alpha: (1 - alpha));
    _drawPixel(pixels, size, x.round() - 1, y.round(), alpha: alpha);
    _drawPixel(pixels, size, y.round(), x.round(), alpha: (1 - alpha));
    _drawPixel(pixels, size, y.round(), x.round() - 1, alpha: alpha);
    _drawPixel(pixels, size, -x.round(), y.round(), alpha: (1 - alpha));
    _drawPixel(pixels, size, -x.round() + 1, y.round(), alpha: alpha);
    _drawPixel(pixels, size, -y.round(), x.round(), alpha: (1 - alpha));
    _drawPixel(pixels, size, -y.round(), x.round() - 1, alpha: alpha);
    _drawPixel(pixels, size, x.round(), -y.round(), alpha: (1 - alpha));
    _drawPixel(pixels, size, x.round() - 1, -y.round(), alpha: alpha);
    _drawPixel(pixels, size, y.round(), -x.round(), alpha: (1 - alpha));
    _drawPixel(pixels, size, y.round(), -x.round() + 1, alpha: alpha);
    _drawPixel(pixels, size, -x.round(), -y.round(), alpha: (1 - alpha));
    _drawPixel(pixels, size, -x.round() + 1, -y.round(), alpha: alpha);
    _drawPixel(pixels, size, -y.round(), -x.round(), alpha: (1 - alpha));
    _drawPixel(pixels, size, -y.round(), -x.round() + 1, alpha: alpha);
  }
}
