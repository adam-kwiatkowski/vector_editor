import 'package:flutter/material.dart';

import 'drawing.dart';

abstract class Tool {
  final String name;
  final IconData icon;

  Tool(this.name, this.icon);

  void onTapDown(Offset offset, Drawing drawing) {}
  void onTapUp(Offset offset, Drawing drawing) {}
  void onTap(Offset offset, Drawing drawing) {}
  void onTapCancel(Offset offset, Drawing drawing) {}
  void onPanStart(Offset offset, Drawing drawing) {}
  void onPanUpdate(Offset offset, Drawing drawing) {}
  void onPanEnd(Offset offset, Drawing drawing) {}
}

class MoveTool extends Tool {
  MoveTool() : super('Move', Icons.north_west_outlined);

  @override
  void onTapDown(Offset offset, Drawing drawing) {
    drawing.selectedObject = drawing.getObjectAt(offset);
  }

  @override
  void onTapUp(Offset offset, Drawing drawing) {
    drawing.selectedObject = null;
  }

  @override
  void onTap(Offset offset, Drawing drawing) {
    drawing.selectedObject = drawing.getObjectAt(offset);
  }

  @override
  void onTapCancel(Offset offset, Drawing drawing) {
    drawing.selectedObject = null;
  }

  @override
  void onPanStart(Offset offset, Drawing drawing) {
    drawing.selectedObject = drawing.getObjectAt(offset);
  }

  @override
  void onPanUpdate(Offset offset, Drawing drawing) {
    if (drawing.selectedObject != null) {
      drawing.selectedObject!.offset = offset;
    }
  }

  @override
  void onPanEnd(Offset offset, Drawing drawing) {
    drawing.selectedObject = null;
  }
}

var presetTools = [
  MoveTool(),
  // LineTool(),
  // CircleTool(),
  // PolygonTool(),
];