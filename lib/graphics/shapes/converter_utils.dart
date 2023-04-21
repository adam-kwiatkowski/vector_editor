import 'circle.dart';
import 'line.dart';
import 'polygon.dart';
import 'semicircle_line.dart';
import 'shape.dart';

class JsonConverter {
  static List<Shape?> fromJsonList(List<dynamic> json) {
    return json.map((e) => fromJson(e)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<Shape> shapes) {
    return shapes.map((e) => toJson(e)).toList();
  }

  static Shape? fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'circle':
        return Circle.fromJson(json);
      case 'line':
        return Line.fromJson(json);
      case 'polygon':
        return Polygon.fromJson(json);
      case 'semicircle_line':
        return SemicircleLine.fromJson(json);
      default:
        return null;
    }
  }

  static Map<String, dynamic> toJson(Shape shape) {
    switch (shape.runtimeType) {
      case Circle:
        return (shape as Circle).toJson();
      case Line:
        return (shape as Line).toJson();
      case Polygon:
        return (shape as Polygon).toJson();
      case SemicircleLine:
        return (shape as SemicircleLine).toJson();
      default:
        return {};
    }
  }
}
