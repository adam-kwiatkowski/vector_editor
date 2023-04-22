import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'shapes/circle.dart';
import 'shapes/line.dart';
import 'shapes/polygon.dart';
import 'shapes/shape.dart';

class Drawing extends ChangeNotifier {
  Drawing(this.size);

  ui.Size size;
  final List<Shape> _objects = [
    Circle(const ui.Offset(400, 200), 50, color: Colors.blue),
    Circle(const ui.Offset(500, 200), 50, color: Colors.yellow),
    Circle(const ui.Offset(600, 200), 50, color: Colors.black),
    Circle(const ui.Offset(450, 250), 50, color: Colors.green),
    Circle(const ui.Offset(550, 250), 50, color: Colors.red),
  ];

  List<Shape> get objects => _objects;

  set objects(List<Shape> value) {
    _objects.clear();
    _objects.addAll(value);
    selectedObject = null;
    selectedHandle = null;
    notifyListeners();
  }

  Shape? selectedObject;
  Handle? selectedHandle;

  Color _color = Colors.black;

  Color get color => _color;

  set color(Color value) {
    _color = value;
    if (selectedObject != null) {
      selectedObject!.color = value;
    }
    notifyListeners();
  }

  Color _canvasColor = Colors.white;

  Color get canvasColor => _canvasColor;

  set canvasColor(Color value) {
    _canvasColor = value;
    notifyListeners();
  }

  int _thickness = 1;

  int get thickness => _thickness;

  set thickness(int value) {
    _thickness = value;
    if (selectedObject != null) {
      if (selectedObject is Line) {
        (selectedObject as Line).thickness = value;
      } else if (selectedObject is Polygon) {
        (selectedObject as Polygon).thickness = value;
      }
    }
    notifyListeners();
  }

  bool _antiAlias = true;

  bool get antiAlias => _antiAlias;

  set antiAlias(bool value) {
    _antiAlias = value;
    notifyListeners();
  }

  Shape? getObjectAt(ui.Offset offset) {
    for (var object in _objects) {
      if (object.contains(offset)) return object;
    }
    return null;
  }

  Handle? getHandleAt(ui.Offset offset) {
    if (selectedObject != null) {
      for (var handle in selectedObject!.handles) {
        if (handle.contains(offset)) return handle;
      }
    }
    return null;
  }

  void selectHandle(Handle handle) {
    selectedHandle = handle;
    notifyListeners();
  }

  void selectObject(Shape object) {
    selectedObject = object;
    notifyListeners();
  }

  void selectObjectAt(ui.Offset offset) {
    bool found = false;
    for (var object in _objects) {
      if (object.contains(offset)) {
        found = true;
        if (selectedObject == object) continue;
        selectObject(object);
        return;
      }
    }
    if (!found) {
      deselectObject();
    }
  }

  void deselectObject() {
    selectedObject = null;
    selectedHandle = null;
    notifyListeners();
  }

  void updateObject(Shape object) {
    notifyListeners();
  }

  void moveObject(Shape object, ui.Offset offset) {
    object.move(offset);
    notifyListeners();
  }

  void moveHandle(Handle handle, ui.Offset offset) {
    handle.onMove(offset);
    notifyListeners();
  }

  void addObject(Shape object) {
    _objects.add(object);
    notifyListeners();
  }

  void removeObject(Shape object) {
    _objects.remove(object);
    notifyListeners();
  }

  void clear() {
    _objects.clear();
    selectedObject = null;
    notifyListeners();
  }

  Uint8List toBytes() {
    final pixels = Uint8List(size.width.toInt() * size.height.toInt() * 4);
    for (var i = 0; i < pixels.length; i += 4) {
      pixels[i] = _canvasColor.red;
      pixels[i + 1] = _canvasColor.green;
      pixels[i + 2] = _canvasColor.blue;
      pixels[i + 3] = _canvasColor.alpha;
    }

    for (var object in _objects) {
      object.draw(pixels, size, antiAlias: antiAlias);
    }

    if (selectedObject != null) {
      selectedObject!.drawHandles(pixels, size);
    }

    return pixels;
  }

  Future<ui.Image> toImage() {
    final pixels = toBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(pixels, size.width.toInt(), size.height.toInt(),
        ui.PixelFormat.rgba8888, completer.complete);
    return completer.future;
  }

  @override
  String toString() {
    return 'Drawing{size: $size, objects: $_objects, selectedObject: $selectedObject, selectedHandle: $selectedHandle, antiAlias: $_antiAlias}';
  }

  void deselectHandle() {
    selectedHandle = null;
    notifyListeners();
  }
}

class Handle {
  Function(ui.Offset) onMove;
  ui.Offset offset;

  Handle(this.offset, {required this.onMove});

  void draw(Uint8List pixels, ui.Size size) {
    final x = offset.dx.toInt();
    final y = offset.dy.toInt();

    for (var i = -5; i <= 5; i++) {
      for (var j = -5; j <= 5; j++) {
        if (x + i >= 0 &&
            x + i < size.width.toInt() &&
            y + j >= 0 &&
            y + j < size.height.toInt()) {
          final index = (x + i + (y + j) * size.width.toInt()) * 4;
          pixels[index] = 0;
          pixels[index + 1] = 0;
          pixels[index + 2] = 0;
          pixels[index + 3] = 255;
        }
      }
    }
    for (var i = -4; i < 5; i++) {
      for (var j = -4; j < 5; j++) {
        if (x + i >= 0 &&
            x + i < size.width.toInt() &&
            y + j >= 0 &&
            y + j < size.height.toInt()) {
          final index = (x + i + (y + j) * size.width.toInt()) * 4;
          pixels[index] = 255;
          pixels[index + 1] = 255;
          pixels[index + 2] = 255;
          pixels[index + 3] = 255;
        }
      }
    }
  }

  bool contains(ui.Offset offset) {
    return (this.offset - offset).distance < 8;
  }
}

class Brush {
  final List<ui.Offset> points;
  final Color color;

  Brush(this.points, {this.color = Colors.black});

  void draw(Uint8List pixels, ui.Size size, ui.Offset offset) {
    for (var point in points) {
      final x = (point.dx + offset.dx).toInt();
      final y = (point.dy + offset.dy).toInt();
      final width = size.width.toInt();
      final height = size.height.toInt();

      if (x >= 0 && x < width && y >= 0 && y < height) {
        final index = (x + y * width) * 4;
        pixels[index] = color.red;
        pixels[index + 1] = color.green;
        pixels[index + 2] = color.blue;
        pixels[index + 3] = color.alpha;
      }
    }
  }

  static Brush rounded(int radius, {Color color = Colors.black}) {
    final points = <ui.Offset>[];
    for (var i = -radius; i < radius; i++) {
      for (var j = -radius; j < radius; j++) {
        if (i * i + j * j >= radius * radius) continue;
        points.add(ui.Offset(i.toDouble(), j.toDouble()));
      }
    }
    return Brush(points, color: color);
  }
}
