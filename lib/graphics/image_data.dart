import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

class ImageData {
  final Uint8List pixels;
  final int width;
  final int height;

  ImageData(this.pixels, this.width, this.height);

  ui.Color getPixel(int x, int y) {
    final index = (x + y * width) * 4;
    return ui.Color.fromARGB(
        pixels[index + 3], pixels[index], pixels[index + 1], pixels[index + 2]);
  }

  toJson() {
    return {'pixels': base64.encode(pixels), 'width': width, 'height': height};
  }

  static ImageData fromJson(Map<String, dynamic> json) {
    return ImageData(
        base64.decode(json['pixels']), json['width'], json['height']);
  }
}
