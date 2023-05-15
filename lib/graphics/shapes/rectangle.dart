import 'dart:typed_data';
import 'dart:ui' as ui;

import '../drawing.dart';
import 'line.dart';
import 'shape.dart';

class Rectangle extends Shape {
  ui.Offset start;
  ui.Offset end;

  Rectangle(this.start, this.end, {super.color}) : super(start);

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
    Line(start, ui.Offset(end.dx, start.dy), color: color).draw(pixels, size);
    Line(ui.Offset(end.dx, start.dy), end, color: color).draw(pixels, size);
    Line(end, ui.Offset(start.dx, end.dy), color: color).draw(pixels, size);
    Line(ui.Offset(start.dx, end.dy), start, color: color).draw(pixels, size);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'rectangle',
      'start': {'dx': start.dx, 'dy': start.dy},
      'end': {'dx': end.dx, 'dy': end.dy},
      'color': color.value
    };
  }

  @override
  void move(ui.Offset offset) {
    start += offset;
    end += offset;
  }
}
