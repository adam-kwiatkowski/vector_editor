import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_editor/graphics/utils.dart';

import 'drawing.dart';

class Line extends Shape {
  final ui.Offset start;
  final ui.Offset end;

  Line(this.start, this.end, {super.color}) : super(start);

  @override
  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = true}) {
    if (antiAlias) {
      wuLine(size, pixels);
    } else {
      ddaLine(size, pixels);
    }
  }

  void ddaLine(ui.Size size, Uint8List pixels) {
    var dy = end.dy - start.dy;
    var dx = end.dx - start.dx;
    var m = dy / dx;
    var y = start.dy;
    for (var x = start.dx; x < end.dx; x++) {
      final index = (x + y.round() * size.width).toInt() * 4;
      pixels[index] = color.red;
      pixels[index + 1] = color.green;
      pixels[index + 2] = color.blue;
      pixels[index + 3] = color.alpha;
      y += m;
    }
  }

  void wuLine(ui.Size size, Uint8List pixels) {
    double x0 = start.dx;
    double y0 = start.dy;
    double x1 = end.dx;
    double y1 = end.dy;

    final steep = (y1 - y0).abs() > (x1 - x0).abs();
    if (steep) {
      double temp;
      temp = x0;
      x0 = y0;
      y0 = temp;
      temp = x1;
      x1 = y1;
      y1 = temp;
    }

    if (x0 > x1) {
      double temp;
      temp = x0;
      x0 = x1;
      x1 = temp;
      temp = y0;
      y0 = y1;
      y1 = temp;
    }

    double dx = x1 - x0;
    double dy = y1 - y0;
    double gradient = dy / dx;

    if (dx == 0.0) {
      gradient = 1.0;
    }

    double xEnd = x0.roundToDouble();
    double yEnd = y0 + gradient * (xEnd - x0);
    double xGap = 1 - (x0 + 0.5).remainder(1);

    double xPixel1 = xEnd;
    double yPixel1 = yEnd.floorToDouble();

    if (steep) {
      _drawPixel(
          size, pixels, yPixel1, xPixel1, xGap * (yEnd - yPixel1).remainder(1));
      _drawPixel(size, pixels, yPixel1 + 1, xPixel1,
          xGap * (1 - (yEnd - yPixel1).remainder(1)));
    } else {
      _drawPixel(
          size, pixels, xPixel1, yPixel1, xGap * (yEnd - yPixel1).remainder(1));
      _drawPixel(size, pixels, xPixel1, yPixel1 + 1,
          xGap * (1 - (yEnd - yPixel1).remainder(1)));
    }

    double interY = yEnd + gradient;

    xEnd = x1.roundToDouble();
    yEnd = y1 + gradient * (xEnd - x1);
    xGap = (x1 + 0.5).remainder(1);

    double xPixel2 = xEnd;
    double yPixel2 = yEnd.floorToDouble();

    if (steep) {
      _drawPixel(
          size, pixels, yPixel2, xPixel2, xGap * (yEnd - yPixel2).remainder(1));
      _drawPixel(size, pixels, yPixel2 + 1, xPixel2,
          xGap * (1 - (yEnd - yPixel2).remainder(1)));
    } else {
      _drawPixel(
          size, pixels, xPixel2, yPixel2, xGap * (yEnd - yPixel2).remainder(1));
      _drawPixel(size, pixels, xPixel2, yPixel2 + 1,
          xGap * (1 - (yEnd - yPixel2).remainder(1)));
    }

    if (steep) {
      for (double x = xPixel1 + 1; x < xPixel2; x++) {
        _drawPixel(
            size, pixels, interY.floorToDouble(), x, 1 - interY.remainder(1));
        _drawPixel(
            size, pixels, interY.floorToDouble() + 1, x, interY.remainder(1));
        interY += gradient;
      }
    } else {
      for (double x = xPixel1 + 1; x < xPixel2; x++) {
        _drawPixel(
            size, pixels, x, interY.floorToDouble(), 1 - interY.remainder(1));
        _drawPixel(
            size, pixels, x, interY.floorToDouble() + 1, interY.remainder(1));
        interY += gradient;
      }
    }
  }

  void _drawPixel(
      ui.Size size, Uint8List pixels, double x, double y, double c) {
    final index = (x.floor() + y.floor() * size.width).toInt() * 4;
    Color backgroundColor =
        getBackgroundColor(pixels, size, x.floor(), y.floor());
    Color blendedColor = blendColors(color.withOpacity(c), backgroundColor);

    pixels[index] = blendedColor.red;
    pixels[index + 1] = blendedColor.green;
    pixels[index + 2] = blendedColor.blue;
    pixels[index + 3] = blendedColor.alpha;
  }
}
