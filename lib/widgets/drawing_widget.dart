import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_editor/graphics/shapes/shape_context_menu_visitor.dart';
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
      builder: (context, constraints) =>
          Consumer<Drawing>(
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

  void showContextMenu(TapDownDetails details, Drawing drawing,
      BuildContext context) {
    var pos = details.globalPosition;

    drawing.selectObjectAt(details.localPosition);

    List<PopupMenuEntry<dynamic>> menuOptions = [
      PopupMenuItem(
        child: ListTile(
          leading: const Icon(Icons.delete_outlined),
          title: const Text('Delete'),
          dense: true,
          contentPadding: EdgeInsets.zero,
          titleTextStyle: Theme
              .of(context)
              .textTheme
              .labelLarge,
        ),
        onTap: () {
          if (drawing.selectedObject != null) {
            drawing.removeObject(drawing.selectedObject!);
          }
        },
      ),
      const PopupMenuDivider(),
    ];

    if (drawing.selectedObject != null) {
      ShapeContextMenuVisitor visitor = ShapeContextMenuVisitor(
          context, drawing);
      drawing.selectedObject!.accept(visitor);
      menuOptions.addAll(visitor.items);
    }

    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
            pos.dx, pos.dy, context.size!.width - pos.dx, 0),
        items: menuOptions.reversed.toList());
  }
}
