import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Drawing extends ChangeNotifier {
  Drawing(this.size);

  ui.Size size;
  final List<Shape> _objects = [];
  List<Shape> get objects => _objects;
  Shape? selectedObject;

  Shape? getObjectAt(ui.Offset offset) {
    for (var object in _objects) {
      if (object.contains(offset)) return object;
    }
    return null;
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
    for (int i = 0; i < pixels.lengthInBytes; i += 4) {
      pixels[i] = 0;
      pixels[i + 1] = 0;
      pixels[i + 2] = 0;
      pixels[i + 3] = 255;
    }
    Point(const Offset(5, 5), 5).draw(pixels, size);
    Point(Offset(size.width - 5, size.height - 5), 5).draw(pixels, size);
    for (var object in _objects) {
      object.draw(pixels, size);
    }
    return pixels;
  }

  Future<ui.Image> toImage() async {
    final pixels = toBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(pixels, size.width.toInt(), size.height.toInt(),
        ui.PixelFormat.rgba8888, completer.complete);
    return completer.future;
  }
}

abstract class Shape {
  ui.Offset offset;

  Shape(this.offset);

  void draw(Uint8List pixels, ui.Size size);

  bool contains(ui.Offset offset) => false;
}

class Point extends Shape {
  final int radius;

  Point(ui.Offset offset, this.radius) : super(offset);

  @override
  void draw(Uint8List pixels, ui.Size size) {
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
