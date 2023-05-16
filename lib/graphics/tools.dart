import 'package:flutter/material.dart';
import 'package:vector_editor/graphics/shapes/rectangle.dart';

import 'drawing.dart';
import 'shapes/circle.dart';
import 'shapes/line.dart';
import 'shapes/polygon.dart';
import 'shapes/semicircle_line.dart';

abstract class Tool {
  final String name;
  final IconData icon;

  Tool(this.name, this.icon);

  void onTapDown(Offset offset, Drawing drawing) {}

  void onTapUp(Offset offset, Drawing drawing) {}

  void onTap(Drawing drawing) {}

  void onTapCancel(Offset offset, Drawing drawing) {}

  void onPanStart(Offset offset, Drawing drawing) {}

  void onPanUpdate(Offset offset, Drawing drawing) {}

  void onPanEnd(Drawing drawing) {}
}

class MoveTool extends Tool {
  MoveTool() : super('Move', Icons.north_west_outlined);
  Offset? _startOffset;

  @override
  void onTapDown(Offset offset, Drawing drawing) {
    if (drawing.selectedObject != null) {
      final handle = drawing.getHandleAt(offset);
      if (handle != null) {
        drawing.selectHandle(handle);
        return;
      }
    }

    drawing.selectObjectAt(offset);
  }

  @override
  void onPanStart(Offset offset, Drawing drawing) {
    _startOffset = offset;

    if (drawing.selectedObject != null) {
      final handle = drawing.getHandleAt(offset);
      if (handle != null) {
        drawing.selectHandle(handle);
        return;
      }
    }

    if (drawing.selectedObject != null) {
      if (drawing.selectedObject!.contains(offset)) return;
    }
    drawing.selectObjectAt(offset);
  }

  @override
  void onPanUpdate(Offset offset, Drawing drawing) {
    if (drawing.selectedHandle != null && _startOffset != null) {
      drawing.moveHandle(drawing.selectedHandle!, offset - _startOffset!);
      _startOffset = offset;
    } else if (drawing.selectedObject != null && _startOffset != null) {
      drawing.moveObject(drawing.selectedObject!, offset - _startOffset!);
      _startOffset = offset;
    }
  }

  @override
  void onPanEnd(Drawing drawing) {
    // drawing.deselectObject();
    drawing.deselectHandle();
  }
}

class LineTool extends Tool {
  LineTool() : super('Line', Icons.draw_outlined);

  @override
  void onPanStart(Offset offset, Drawing drawing) {
    final line = Line(offset, offset,
        outlineColor: drawing.color, thickness: drawing.thickness);
    drawing.addObject(line);
    drawing.selectObject(line);
  }

  @override
  void onPanUpdate(Offset offset, Drawing drawing) {
    if (drawing.selectedObject != null) {
      final line = drawing.selectedObject as Line;
      line.end = offset;

      if (line.start == line.end) {
        drawing.removeObject(line);
        drawing.deselectObject();
      } else {
        drawing.updateObject(line);
      }
    }
  }

  @override
  void onPanEnd(Drawing drawing) {
    drawing.deselectObject();
  }
}

class CircleTool extends Tool {
  CircleTool() : super('Circle', Icons.circle_outlined);

  @override
  void onPanStart(Offset offset, Drawing drawing) {
    final circle = Circle(offset, 0, outlineColor: drawing.color);
    drawing.deselectObject();
    drawing.addObject(circle);
    drawing.selectObject(circle);
  }

  @override
  void onPanUpdate(Offset offset, Drawing drawing) {
    if (drawing.selectedObject != null) {
      final circle = drawing.selectedObject as Circle;
      circle.radius = (circle.offset - offset).distance.round();
      drawing.updateObject(circle);
    }
  }
}

class RectangleTool extends Tool {
  RectangleTool() : super('Rectangle', Icons.square_outlined);

  @override
  void onPanStart(Offset offset, Drawing drawing) {
    final rectangle = Rectangle(offset, offset,
        outlineColor: drawing.color);
    drawing.addObject(rectangle);
    drawing.selectObject(rectangle);
  }

  @override
  void onPanUpdate(Offset offset, Drawing drawing) {
    if (drawing.selectedObject != null) {
      final rectangle = drawing.selectedObject as Rectangle;
      rectangle.end = offset;

      if (rectangle.start == rectangle.end) {
        drawing.removeObject(rectangle);
        drawing.deselectObject();
      } else {
        drawing.updateObject(rectangle);
      }
    }
  }

  @override
  void onPanEnd(Drawing drawing) {
    drawing.deselectObject();
  }
}

class PolygonTool extends Tool {
  PolygonTool() : super('Polygon', Icons.pentagon_outlined);

  @override
  void onTapDown(Offset offset, Drawing drawing) {
    if (drawing.selectedObject != null) {
      if (drawing.selectedObject is! Polygon) {
        drawing.deselectObject();
        return;
      }
      final polygon = drawing.selectedObject as Polygon;
      polygon.points.add(offset);
      drawing.updateObject(polygon);

      if (polygon.points.length > 2) {
        final firstPoint = polygon.points.first;
        final lastPoint = polygon.points.last;
        if ((firstPoint - lastPoint).distance < 10) {
          polygon.points.removeLast();
          polygon.closed = true;
          drawing.updateObject(polygon);
          drawing.deselectObject();
        }
      }
    } else {
      final polygon = Polygon([offset], offset,
          outlineColor: drawing.color, thickness: drawing.thickness);
      drawing.addObject(polygon);
      drawing.selectObject(polygon);
    }
  }
}

class SemicircleLineTool extends Tool {
  SemicircleLineTool() : super('Semicircle Line', Icons.shape_line_outlined);

  @override
  void onPanStart(Offset offset, Drawing drawing) {
    final line = SemicircleLine(offset, offset, 5, outlineColor: drawing.color);
    drawing.addObject(line);
    drawing.selectObject(line);
  }

  @override
  void onPanUpdate(Offset offset, Drawing drawing) {
    if (drawing.selectedObject != null) {
      final line = drawing.selectedObject as SemicircleLine;
      line.end = offset;

      if (line.start == line.end) {
        drawing.removeObject(line);
        drawing.deselectObject();
      } else {
        drawing.updateObject(line);
      }
    }
  }

  @override
  void onPanEnd(Drawing drawing) {
    drawing.deselectObject();
  }
}

class EraserTool extends Tool {
  EraserTool() : super('Eraser', Icons.backspace_outlined);

  @override
  void onTapDown(Offset offset, Drawing drawing) {
    if (drawing.selectedObject != null) {
      if (drawing.selectedObject! is Polygon) {
        final polygon = drawing.selectedObject as Polygon;
        polygon.removePointAt(offset);
        drawing.updateObject(polygon);
        if (polygon.points.length < 2) {
          drawing.deselectObject();
          drawing.removeObject(polygon);
        }
        return;
      }
    }

    final object = drawing.getObjectAt(offset);
    if (object != null) {
      drawing.deselectObject();
      drawing.removeObject(object);
    }
  }
}

var presetTools = [
  MoveTool(),
  LineTool(),
  CircleTool(),
  RectangleTool(),
  PolygonTool(),
  SemicircleLineTool(),
  EraserTool(),
];
