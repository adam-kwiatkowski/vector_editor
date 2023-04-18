import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_editor/graphics/semicircle_line.dart';

import 'circle.dart';
import 'line.dart';
import 'polygon.dart';

class Drawing extends ChangeNotifier {
  Drawing(this.size);

  ui.Size size;
  final List<Shape> _objects = [
    Point(const Offset(5, 5), 5),
    Line(const Offset(5, 5), const Offset(200, 100), color: Colors.green),
    Line(const Offset(200, 500), const Offset(300, 495), color: Colors.green),
    Line(const Offset(100, 350), const Offset(300, 350), color: Colors.blue),
    Circle(const Offset(200, 350), 100),
    Circle(const Offset(200, 350), 50,
        full: false, startAngle: pi, endAngle: 2 * pi),
    Polygon([
      const Offset(100, 100),
      const Offset(200, 100),
      const Offset(200, 200),
      const Offset(100, 200),
    ], const Offset(150, 150)),
    SemicircleLine(const Offset(400, 200), const Offset(500, 300), 5),
    SemicircleLine(const Offset(400, 200), const Offset(500, 100), 5),
    SemicircleLine(const Offset(400, 200), const Offset(300, 300), 5),
    SemicircleLine(const Offset(400, 200), const Offset(300, 100), 5),
  ];

  List<Shape> get objects => _objects;
  Shape? selectedObject;
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

  void selectObject(Shape object) {
    selectedObject = object;
    notifyListeners();
  }

  void deselectObject() {
    selectedObject = null;
    notifyListeners();
  }

  void updateObject(Shape object) {
    notifyListeners();
  }

  void moveObject(Shape object, ui.Offset offset) {
    object.move(offset);
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
    notifyListeners();
  }

  Uint8List toBytes() {
    final pixels = Uint8List(size.width.toInt() * size.height.toInt() * 4);
    pixels.fillRange(0, pixels.length, 255);

    for (var object in _objects) {
      object.draw(pixels, size, antiAlias: antiAlias);
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
}

abstract class Shape {
  ui.Offset offset;
  Color color;

  Shape(this.offset, {this.color = Colors.black});

  void draw(Uint8List pixels, ui.Size size, {bool antiAlias = false});

  void move(ui.Offset offset) {
    this.offset += offset;
  }

  bool contains(ui.Offset offset) => false;
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
