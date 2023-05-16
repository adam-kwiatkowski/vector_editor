import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vector_editor/graphics/drawing.dart';
import 'package:vector_editor/graphics/shapes/circle.dart';
import 'package:vector_editor/graphics/shapes/line.dart';
import 'package:vector_editor/graphics/shapes/polygon.dart';
import 'package:vector_editor/graphics/shapes/rectangle.dart';
import 'package:vector_editor/graphics/shapes/semicircle_line.dart';
import 'package:vector_editor/graphics/shapes/shape.dart';
import 'package:vector_editor/graphics/shapes/shape_visitor.dart';

class ShapeContextMenuVisitor extends ShapeVisitor {
  final BuildContext context;
  final Drawing drawing;
  final List<PopupMenuEntry<dynamic>> _items = [];

  ShapeContextMenuVisitor(this.context, this.drawing);

  List<PopupMenuEntry<dynamic>> get items => _items;

  @override
  void visitCircle(Circle circle) {
    _items.add(
        buildMenuItem(Icons.color_lens_outlined, 'Change outline color', () {
      showOutlineColorPicker(circle);
    }));
  }

  @override
  void visitLine(Line line) {
    _items.addAll([
      buildMenuItem(Icons.color_lens_outlined, 'Change outline color', () {
        showOutlineColorPicker(line);
      }),
      buildMenuItem(Icons.line_weight, 'Change thickness', () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
              context: context,
              builder: (context) => LineThicknessDialog(
                    thickness: line.thickness,
                    onThicknessChanged: (thickness) {
                      line.thickness = thickness;
                      drawing.updateObject(line);
                    },
                  ));
        });
      }),
    ]);
  }

  @override
  void visitPolygon(Polygon polygon) {
    _items.addAll([
      buildMenuItem(Icons.color_lens_outlined, 'Change outline color', () {
        showOutlineColorPicker(polygon);
      }),
      buildMenuItem(Icons.line_weight, 'Change thickness', () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
              context: context,
              builder: (context) => LineThicknessDialog(
                    thickness: polygon.thickness,
                    onThicknessChanged: (thickness) {
                      polygon.thickness = thickness;
                      drawing.updateObject(polygon);
                    },
                  ));
        });
      }),
    ]);
  }

  @override
  void visitRectangle(Rectangle rectangle) {
    _items.addAll([
      buildMenuItem(Icons.color_lens_outlined, 'Change outline color', () {
        showOutlineColorPicker(rectangle);
      }),
      buildMenuItem(Icons.line_weight, 'Change thickness', () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
              context: context,
              builder: (context) => LineThicknessDialog(
                    thickness: rectangle.thickness,
                    onThicknessChanged: (thickness) {
                      rectangle.thickness = thickness;
                      drawing.updateObject(rectangle);
                    },
                  ));
        });
      }),
    ]);
  }

  @override
  void visitSemicircleLine(SemicircleLine semicircleLine) {
    _items.add(
        buildMenuItem(Icons.color_lens_outlined, 'Change outline color', () {
      showOutlineColorPicker(semicircleLine);
    }));
  }

  void showOutlineColorPicker(Shape shape) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Outline color'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: shape.outlineColor,
                    onColorChanged: (color) {
                      shape.outlineColor = color;
                      drawing.updateObject(shape);
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ));
    });
  }

  PopupMenuItem<dynamic> buildMenuItem(
      IconData icon, String title, Function() onTap) {
    return PopupMenuItem(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        dense: true,
        contentPadding: EdgeInsets.zero,
        titleTextStyle: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class LineThicknessDialog extends StatefulWidget {
  final int thickness;
  final Function(int) onThicknessChanged;

  const LineThicknessDialog(
      {super.key, required this.thickness, required this.onThicknessChanged});

  @override
  State<StatefulWidget> createState() => _LineThicknessDialogState();
}

class _LineThicknessDialogState extends State<LineThicknessDialog> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.thickness.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thickness'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _sliderValue,
            min: 1,
            max: 10,
            divisions: 9,
            label: _sliderValue.round().toString(),
            onChanged: (value) {
              widget.onThicknessChanged(value.round());
              setState(() {
                _sliderValue = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
