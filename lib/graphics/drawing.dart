import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'circle.dart';
import 'line.dart';
import 'polygon.dart';

class Drawing extends ChangeNotifier {
  Drawing(this.size);

  ui.Size size;
  final List<Shape> _objects = [
    Line(const Offset(200, 500), const Offset(300, 495), color: Colors.green, thickness: 5),
    Line(const Offset(100, 350), const Offset(300, 350), color: Colors.blue),
    Circle(const Offset(200, 350), 100),
    Circle(const Offset(200, 350), 50,
        full: false, startAngle: pi, endAngle: 2 * pi),
    Polygon([
      const Offset(100, 100),
      const Offset(200, 100),
      const Offset(200, 200),
      const Offset(100, 200),
    ], const Offset(150, 150), closed: true, thickness: 4),
  ];

  List<Shape> get objects => _objects;
  Shape? selectedObject;
  Handle? selectedHandle;
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
    pixels.fillRange(0, pixels.length, 255);

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

abstract class Shape {
  ui.Offset offset;
  Color color;

  List<Handle> get handles => [];

  Shape(this.offset, {this.color = Colors.black});

  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = false});

  bool contains(ui.Offset offset) => false;

  void move(ui.Offset offset) {
    this.offset += offset;

    for (var handle in handles) {
      handle.offset += offset;
    }
  }

  void drawHandles(Uint8List pixels, ui.Size size) {
    for (var handle in handles) {
      handle.draw(pixels, size);
    }
  }
}

class Point extends Shape {
  final int radius;

  Point(ui.Offset offset, this.radius) : super(offset);

  @override
  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = false}) {
    final x = offset.dx.toInt();
    final y = offset.dy.toInt();
    final width = size.width.toInt();
    final height = size.height.toInt();

    for (var i = -radius; i < radius; i++) {
      for (var j = -radius; j < radius; j++) {
        if (i * i + j * j >= radius * radius) continue;
        if (x + i >= 0 && x + i < width && y + j >= 0 && y + j < height) {
          final index = (x + i + (y + j) * width) * 4;
          pixels[index] = 255;
          pixels[index + 1] = 0;
          pixels[index + 2] = 0;
          pixels[index + 3] = 255;
        }
      }
    }
  }

  @override
  bool contains(ui.Offset offset) {
    return (this.offset - offset).distance < radius;
  }
}

class Handle {
  Function(ui.Offset) onMove;
  ui.Offset offset;

  Handle(this.offset, {required this.onMove});

  void draw(Uint8List pixels, ui.Size size) {
    final x = offset.dx.toInt();
    final y = offset.dy.toInt();

  //   draw a 5x5 white square with a black outline
    for (var i = -5; i <= 5; i++) {
      for (var j = -5; j <= 5; j++) {
        if (x + i >= 0 && x + i < size.width.toInt() && y + j >= 0 && y + j < size.height.toInt()) {
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
        if (x + i >= 0 && x + i < size.width.toInt() && y + j >= 0 && y + j < size.height.toInt()) {
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