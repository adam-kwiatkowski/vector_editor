import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DrawingA extends ChangeNotifier {
  final List<GraphicsObject> objects;
  ui.Size size;
  GraphicsObject? selectedObject;
  final ValueNotifier<ui.Image?> imageNotifier = ValueNotifier(null);

  DrawingA(this.size, {this.objects = const []});

  void drawObjects(Uint8List pixels) {
    for (final object in objects) {
      object.draw(pixels, size);
    }
  }

  void updateDrawing() async {
    var image = await toImage();
    imageNotifier.value = image;
    notifyListeners();
  }

  void updateObject(GraphicsObject object) {
    int index = objects.indexOf(object);
    if (index != -1) {
      objects[index] = object;
      updateDrawing();
    }
  }

  void addObject(GraphicsObject object) {
    objects.add(object);
    updateDrawing();
  }

  GraphicsObject? getObjectAt(ui.Offset offset) {
    for (final object in objects) {
      if (object.contains(offset)) {
        return object;
      }
    }
    return null;
  }

  Future<ui.Image> toImage() async {
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

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      size.width.toInt(),
      size.height.toInt(),
      ui.PixelFormat.rgba8888,
          (image) => completer.complete(image),
    );

    return completer.future;
  }

  Future<ImageProvider> toImageProvider() async {
    final pixels = Uint8List(size.width.toInt() * size.height.toInt() * 4);
    drawObjects(pixels);
    final image = MemoryImage(pixels);
    return image;
  }
}

abstract class GraphicsObject {
  ui.Offset offset;

  GraphicsObject(this.offset);

  void draw(Uint8List pixels, ui.Size size);
  bool contains(ui.Offset offset) => false;
}

class Point extends GraphicsObject {
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