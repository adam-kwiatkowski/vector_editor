import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';

class Drawing {
  final List<GraphicsObject> objects;
  Size size;
  bool enableGizmos = false;
  GraphicsObject? selectedObject;

  Drawing(this.size, {this.objects = const []});

  void drawObjects(Uint8List pixels) {
    for (final object in objects) {
      object.draw(pixels, size);
    }
  }

  void drawGizmos(Uint8List pixels) {
    for (final object in objects) {
      object.drawGizmos(pixels, size);
    }

    Point(const Offset(0, 0), 5).draw(pixels, size);
    Point(Offset(size.width, size.height), 5).draw(pixels, size);
  }

  GraphicsObject? getObjectAt(Offset offset) {
    for (final object in objects) {
      if (object.contains(offset)) {
        return object;
      }
    }
    return null;
  }

  Future<Image> toImage() async {
    final pixels = Uint8List.fromList(
      List.generate(
        size.width.toInt() * size.height.toInt() * 4,
        (index) => 0,
      ),
    );
    for (int i = 0; i < pixels.lengthInBytes; i += 4) {
      pixels[i+3] = 255;
    }

    drawObjects(pixels);
    if (enableGizmos) drawGizmos(pixels);

    final completer = Completer<Image>();
    decodeImageFromPixels(
      pixels,
      size.width.toInt(),
      size.height.toInt(),
      PixelFormat.rgba8888,
      completer.complete,
    );

    return completer.future;
  }
}

abstract class GraphicsObject {
  Offset offset;

  GraphicsObject(this.offset);

  void draw(Uint8List pixels, Size size);
  void drawGizmos(Uint8List pixels, Size size) {}
  bool contains(Offset offset) => false;
}

class Point extends GraphicsObject {
  final int radius;

  Point(Offset offset, this.radius) : super(offset);

  @override
  void draw(Uint8List pixels, Size size) {
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
  bool contains(Offset offset) {
    return (this.offset - offset).distance < radius;
  }
}