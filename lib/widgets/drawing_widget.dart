import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
}
