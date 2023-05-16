import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:vector_editor/graphics/shapes/line.dart';
import 'package:vector_editor/graphics/shapes/polygon.dart';
import 'package:vector_editor/graphics/tools.dart';

import '../graphics/drawing.dart';

class DrawingWidget extends StatefulWidget {
  const DrawingWidget(this.selectedTool, {super.key});

  final int selectedTool;

  @override
  DrawingWidgetState createState() => DrawingWidgetState();
}

class DrawingWidgetState extends State<DrawingWidget> {
  @override
  Widget build(BuildContext context) {
    final tool = presetTools[widget.selectedTool];
    return LayoutBuilder(
      builder: (context, constraints) => Consumer<Drawing>(
        builder: (context, drawing, child) {
          drawing.size = Size(constraints.maxWidth, constraints.maxHeight);
          return RepaintBoundary(
            child: GestureDetector(
              onTapDown: (details) {
                tool.onTapDown(details.localPosition, drawing);
              },
              onTapUp: (details) {
                tool.onTapUp(details.localPosition, drawing);
              },
              onPanStart: (details) {
                tool.onPanStart(details.localPosition, drawing);
              },
              onPanUpdate: (details) {
                tool.onPanUpdate(details.localPosition, drawing);
              },
              onPanEnd: (details) {
                tool.onPanEnd(drawing);
              },
              onSecondaryTapDown: (details) {
                showContextMenu(details, drawing, context);
              },
              child: FutureBuilder<ui.Image>(
                future: drawing.toImage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Stack(children: [
                      RawImage(
                        alignment: Alignment.topLeft,
                        fit: BoxFit.none,
                        image: snapshot.data!,
                        width: drawing.size.width,
                        height: drawing.size.height,
                        filterQuality: FilterQuality.none,
                      ),
                      // Text(drawing.toString())
                    ]);
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void showContextMenu(
      TapDownDetails details, Drawing drawing, BuildContext context) {
    var pos = details.globalPosition;

    drawing.selectObjectAt(details.localPosition);

    List<PopupMenuEntry<dynamic>> menuOptions = [
      PopupMenuItem(
        child: ListTile(
          leading: const Icon(Icons.delete_forever_outlined),
          title: const Text('Clear all'),
          dense: true,
          contentPadding: EdgeInsets.zero,
          titleTextStyle: Theme.of(context).textTheme.labelLarge,
        ),
        onTap: () {
          setState(() {
            drawing.clear();
          });
        },
      ),
    ];

    if (drawing.selectedObject != null) {
      menuOptions.add(const PopupMenuDivider());
      menuOptions.addAll([
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            titleTextStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onTap: () {
            setState(() {
              drawing.removeObject(drawing.selectedObject!);
            });
          },
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Outline color'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            titleTextStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Outline color'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: drawing.selectedObject!.outlineColor,
                            onColorChanged: (color) {
                              setState(() {
                                drawing.selectedObject!.outlineColor = color;
                              });
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
          },
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.line_weight),
            title: const Text('Outline width'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            titleTextStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              var selectedObject = drawing.selectedObject;
              var thickness = selectedObject is Line
                  ? selectedObject.thickness
                  : selectedObject is Polygon
                      ? selectedObject.thickness
                      : 1;
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Outline width'),
                        content: SingleChildScrollView(
                          child: Slider(
                            value: thickness.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: thickness
                                .round()
                                .toString(),
                            onChanged: (value) {
                              setState(() {
                                if (selectedObject != null) {
                                  if (selectedObject is Line) {
                                    (selectedObject).thickness = value.round();
                                  } else if (selectedObject is Polygon) {
                                    (selectedObject).thickness = value.round();
                                  }
                                }
                              });
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
          },
        )
      ]);
    }

    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
            pos.dx, pos.dy, context.size!.width - pos.dx, 0),
        items: menuOptions.reversed.toList());
  }
}
