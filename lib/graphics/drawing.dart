import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

class Drawing {
  final List<GraphicsObject> objects;
  Size size;

  Drawing(this.size, this.objects);

  void drawObjects(Uint8List pixels) {
    for (final object in objects) {
      object.draw(pixels, size);
    }
  }

  Future<Image> toImage() async {
    final pixels = Uint8List.fromList(
      List.generate(
        size.width.toInt() * size.height.toInt() * 4,
        (index) => 0,
      ),
    );
    drawObjects(pixels);

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
  final Offset offset;

  GraphicsObject(this.offset);

  void draw(Uint8List pixels, Size size);
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
        if (i * i + j * j > radius * radius) continue;
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
}