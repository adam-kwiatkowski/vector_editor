import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_editor/graphics/shapes/shape_visitor.dart';
import 'package:vector_editor/graphics/utils.dart';

import '../drawing.dart';
import 'shape.dart';

class Line extends Shape {
  ui.Offset start;
  ui.Offset end;
  int thickness;

  Line(this.start, this.end, {super.outlineColor, this.thickness = 1}) : super(start);

  @override
  List<Handle> get handles => [
        Handle(
          start,
          onMove: (offset) {
            start += offset;
          },
        ),
        Handle(
          end,
          onMove: (offset) {
            end += offset;
          },
        ),
      ];

  @override
  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = true}) {
    if (thickness != 1) {
      final brush = Brush.rounded(thickness, color: outlineColor);
      brushLine(size, pixels, brush);
    } else if (antiAlias) {
      wuLine(size, pixels);
    } else {
      ddaLine(size, pixels);
    }
  }

  @override
  bool contains(ui.Offset offset) {
    //   true if point is within 5 pixels of the line
    final distance = (end - start).distance;
    final distance1 = (offset - start).distance;
    final distance2 = (offset - end).distance;
    return (distance1 + distance2 - distance).abs() < 5;
  }

  void brushLine(ui.Size size, Uint8List pixels, Brush brush) {
    var dy = end.dy - start.dy;
    var dx = end.dx - start.dx;
    var steps = dy.abs() > dx.abs() ? dy.abs() : dx.abs();

    dx = dx / steps;
    dy = dy / steps;

    var x = start.dx;
    var y = start.dy;

    for (var i = 0; i <= steps; i++) {
      brush.draw(pixels, size, Offset(x, y));
      x += dx;
      y += dy;
    }
  }

  void ddaLine(ui.Size size, Uint8List pixels) {
    var dy = end.dy - start.dy;
    var dx = end.dx - start.dx;
    var steps = dy.abs() > dx.abs() ? dy.abs() : dx.abs();

    dx = dx / steps;
    dy = dy / steps;

    var x = start.dx;
    var y = start.dy;

    for (var i = 0; i <= steps; i++) {
      _drawPixel(size, pixels, x, y, 1.0);
      x += dx;
      y += dy;
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
    if (index < 0 ||
        index >= pixels.length ||
        c < 0 ||
        c > 1 ||
        x < 0 ||
        x >= size.width ||
        y < 0 ||
        y >= size.height) {
      return;
    }
    Color backgroundColor =
        getBackgroundColor(pixels, size, x.floor(), y.floor());
    Color blendedColor = blendColors(outlineColor.withOpacity(c), backgroundColor);

    pixels[index] = blendedColor.red;
    pixels[index + 1] = blendedColor.green;
    pixels[index + 2] = blendedColor.blue;
    pixels[index + 3] = blendedColor.alpha;
  }

  @override
  void move(ui.Offset offset) {
    start += offset;
    end += offset;
    this.offset += offset;
  }

  static Shape? fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'line') {
      return Line(
        Offset(json['start']['dx'], json['start']['dy']),
        Offset(json['end']['dx'], json['end']['dy']),
        outlineColor: Color(json['color']),
        thickness: json['thickness'],
      );
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'line',
      'start': {'dx': start.dx, 'dy': start.dy},
      'end': {'dx': end.dx, 'dy': end.dy},
      'color': outlineColor.value,
      'thickness': thickness,
    };
  }

  @override
  void accept(ShapeVisitor visitor) {
    visitor.visitLine(this);
  }
}
