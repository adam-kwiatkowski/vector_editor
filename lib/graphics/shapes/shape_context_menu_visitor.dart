import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vector_editor/graphics/drawing.dart';
import 'package:vector_editor/graphics/image_data.dart';
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
      buildMenuItem(Icons.image_outlined, 'Fill with image',
          () => showImagePicker(polygon)),
      buildMenuItem(Icons.color_lens_outlined, 'Change outline color',
          () => showOutlineColorPicker(polygon)),
      buildMenuItem(Icons.format_color_fill_outlined, 'Change fill color',
          () => showFillColorPicker(polygon)),
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

  void showFillColorPicker(Polygon polygon) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Fill color'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: polygon.fillColor ?? Colors.transparent,
                    onColorChanged: (fillColor) {
                      polygon.fillColor = fillColor;
                      polygon.fillImage = null;
                      drawing.updateObject(polygon);
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

  showImagePicker(Polygon polygon) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
          context: context,
          builder: (context) =>
              FillImageDialog(drawing: drawing, polygon: polygon));
    });
  }
}

class FillImageDialog extends StatefulWidget {
  const FillImageDialog({
    super.key,
    required this.drawing,
    required this.polygon,
  });

  final Drawing drawing;
  final Polygon polygon;

  @override
  State<FillImageDialog> createState() => _FillImageDialogState();
}

class _FillImageDialogState extends State<FillImageDialog> {
  ImageData? image;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fill with image'),
      content: SingleChildScrollView(
        child: ImagePicker(
          onImagePicked: (imageFile) async {
            var bytes = await imageFile.readAsBytes();
            decodeImageFromList(bytes).then((image) {
              var width = image.width;
              var height = image.height;
              image.toByteData().then((data) {
                var imageData = ImageData(
                  data!.buffer.asUint8List(),
                  width,
                  height,
                );
                setState(() {
                  this.image = imageData;
                });
              });
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.polygon.fillImage = image;
            widget.polygon.fillColor = null;
            widget.drawing.updateObject(widget.polygon);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class ImagePicker extends StatefulWidget {
  final Function(XFile) onImagePicked;

  const ImagePicker({Key? key, required this.onImagePicked}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  XFile? _imageFile;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) {
        setState(() {
          _isDragging = true;
        });
      },
      onDragExited: (details) {
        setState(() {
          _isDragging = false;
        });
      },
      onDragDone: (details) async {
        setState(() {
          _isDragging = false;
          _imageFile = details.files.first;
          if (_imageFile!.path.endsWith('.png') ||
              _imageFile!.path.endsWith('.jpg')) {
            widget.onImagePicked(_imageFile!);
          } else {
            _imageFile = null;
          }
        });
      },
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              // rounded dashed border
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isDragging
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  _buildImage(Theme.of(context).primaryColor),
                  const SizedBox(height: 10),
                  Text(
                    'Drop an image here',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  TextButton(
                      onPressed: () => _showFilePicker(),
                      child: const Text('or select from files')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildImage(Color iconColor) {
    if (_imageFile != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        width: 300,
        height: 300,
        clipBehavior: Clip.antiAlias,
        child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
      );
    } else if (_isDragging) {
      return Icon(Icons.file_upload, color: iconColor);
    } else {
      return Icon(Icons.image_outlined, color: iconColor);
    }
  }

  _showFilePicker() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageFile = XFile(result.files.single.path!);
        widget.onImagePicked(_imageFile!);
      });
    }
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
