import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Color getBackgroundColor(Uint8List pixels, ui.Size size, int x, int y) {
  final index = (x + y * size.width).toInt() * 4;
  return Color.fromARGB(
    pixels[index + 3],
    pixels[index],
    pixels[index + 1],
    pixels[index + 2],
  );
}

Color blendColors(Color foreground, Color background) {
  final alpha = foreground.alpha / 255;
  final red = (foreground.red * alpha + background.red * (1 - alpha)).round();
  final green =
  (foreground.green * alpha + background.green * (1 - alpha)).round();
  final blue =
  (foreground.blue * alpha + background.blue * (1 - alpha)).round();
  return Color.fromARGB(255, red, green, blue);
}