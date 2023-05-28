import 'circle.dart';
import 'line.dart';
import 'polygon.dart';
import 'rectangle.dart';
import 'semicircle_line.dart';

abstract class ShapeVisitor {
  void visitCircle(Circle circle);

  void visitLine(Line line);

  void visitPolygon(Polygon polygon);

  void visitRectangle(Rectangle rectangle);

  void visitSemicircleLine(SemicircleLine semicircleLine);
}
