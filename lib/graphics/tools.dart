import 'package:flutter/material.dart';

import 'drawing.dart';

abstract class Tool {
  final String name;
  final IconData icon;

  Tool(this.name, this.icon);

  void onTapDown(Offset offset, DrawingA drawing) {}
  void onTapUp(Offset offset, DrawingA drawing) {}
  void onTap(Offset offset, DrawingA drawing) {}
  void onTapCancel(Offset offset, DrawingA drawing) {}
  void onPanStart(Offset offset, DrawingA drawing) {}
  void onPanUpdate(Offset offset, DrawingA drawing) {}
  void onPanEnd(Offset offset, DrawingA drawing) {}
}

class MoveTool extends Tool {
  MoveTool() : super('Move', Icons.north_west_outlined);

  @override
  void onTapDown(Offset offset, DrawingA drawing) {
    drawing.selectedObject = drawing.getObjectAt(offset);
  }

  @override
  void onTapUp(Offset offset, DrawingA drawing) {
    drawing.selectedObject = null;
  }

  @override
  void onTap(Offset offset, DrawingA drawing) {
    drawing.selectedObject = drawing.getObjectAt(offset);
  }

  @override
  void onTapCancel(Offset offset, DrawingA drawing) {
    drawing.selectedObject = null;
  }

  @override
  void onPanStart(Offset offset, DrawingA drawing) {
    drawing.selectedObject = drawing.getObjectAt(offset);
  }

  @override
  void onPanUpdate(Offset offset, DrawingA drawing) {
    if (drawing.selectedObject != null) {
      drawing.selectedObject!.offset = offset;
    }
  }

  @override
  void onPanEnd(Offset offset, DrawingA drawing) {
    drawing.selectedObject = null;
  }
}

var presetTools = [
  MoveTool(),
  // LineTool(),
  // CircleTool(),
  // PolygonTool(),
];