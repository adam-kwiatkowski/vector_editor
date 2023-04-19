import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'circle.dart';
import 'drawing.dart';
import 'line.dart';

class SemicircleLine extends Shape {
  final int N;
  ui.Offset start;
  ui.Offset end;

  SemicircleLine(this.start, this.end, this.N, {super.color}) : super(start);

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
  void move(ui.Offset offset) {
    start += offset;
    end += offset;
  }

  @override
  bool contains(ui.Offset offset) {
    var distance = (end - start).distance;
    var distance1 = (offset - start).distance;
    var distance2 = (offset - end).distance;
    return (distance1 + distance2 - distance).abs() < 5;
  }

  @override
  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = false}) {
    var line = Line(start, end, color: color);
    line.draw(pixels, size, antiAlias: antiAlias);

    var length = (end - start).distance;
    var radius = (length / (2 * N)).round();

    var lineAngle = atan2(end.dy - start.dy, end.dx - start.dx);

    var angleStart = lineAngle + pi;
    var angleEnd = angleStart + pi;
    if (lineAngle > pi / 2 && lineAngle < 3 * pi / 2) {
      angleEnd = lineAngle + pi;
      angleStart = angleEnd - pi;
    } else if (lineAngle < -pi / 2 && lineAngle > -3 * pi / 2) {
      angleEnd = lineAngle + pi;
      angleStart = angleEnd - pi;
    }

    for (var i = 0; i < N; i++) {
      var circle = Circle(
          start + (end - start) * (2 * i + 1) / (2 * N).toDouble(), radius,
          color: color,
          full: false,
          startAngle: angleStart,
          endAngle: angleEnd);
      circle.draw(pixels, size, antiAlias: antiAlias);
    }
  }
}
