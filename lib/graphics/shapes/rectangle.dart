import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:vector_editor/graphics/shapes/shape_visitor.dart';

import '../drawing.dart';
import 'line.dart';
import 'shape.dart';

class Rectangle extends Shape {
  ui.Offset start;
  ui.Offset end;
  int thickness;

  ui.Size get size =>
      ui.Size((end.dx - start.dx).abs(), (end.dy - start.dy).abs());

  double get left => min(start.dx, end.dx);

  double get top => min(start.dy, end.dy);

  double get right => max(start.dx, end.dx);

  double get bottom => max(start.dy, end.dy);

  Rectangle(this.start, this.end, {super.outlineColor, this.thickness = 1})
      : super(start);

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
        Handle(ui.Offset(start.dx, end.dy), onMove: (offset) {
          start += ui.Offset(offset.dx, 0);
          end += ui.Offset(0, offset.dy);
        }),
        Handle(ui.Offset(end.dx, start.dy), onMove: (offset) {
          start += ui.Offset(0, offset.dy);
          end += ui.Offset(offset.dx, 0);
        })
      ];

  @override
  bool contains(ui.Offset offset) {
    return ((offset.dx - start.dx).abs() + (offset.dx - end.dx).abs() ==
            (start.dx - end.dx).abs()) &&
        ((offset.dy - start.dy).abs() + (offset.dy - end.dy).abs() ==
            (start.dy - end.dy).abs());
  }

  @override
  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = false}) {
    Line(start, ui.Offset(end.dx, start.dy),
            outlineColor: outlineColor, thickness: thickness)
        .draw(pixels, size);
    Line(ui.Offset(end.dx, start.dy), end,
            outlineColor: outlineColor, thickness: thickness)
        .draw(pixels, size);
    Line(end, ui.Offset(start.dx, end.dy),
            outlineColor: outlineColor, thickness: thickness)
        .draw(pixels, size);
    Line(ui.Offset(start.dx, end.dy), start,
            outlineColor: outlineColor, thickness: thickness)
        .draw(pixels, size);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'rectangle',
      'start': {'dx': start.dx, 'dy': start.dy},
      'end': {'dx': end.dx, 'dy': end.dy},
      'color': outlineColor.value
    };
  }

  @override
  void move(ui.Offset offset) {
    start += offset;
    end += offset;
  }

  @override
  void accept(ShapeVisitor visitor) {
    visitor.visitRectangle(this);
  }
}
