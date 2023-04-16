import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../graphics/drawing.dart';

class DrawingWidget extends StatefulWidget {
  const DrawingWidget({super.key});

  @override
  DrawingWidgetState createState() => DrawingWidgetState();
}

class DrawingWidgetState extends State<DrawingWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Consumer<Drawing>(
        builder: (context, drawing, child) {
          drawing.size = Size(constraints.maxWidth, constraints.maxHeight);
          return RepaintBoundary(
            child: GestureDetector(
              onTapUp: (details) {
                drawing.addObject(Point(details.localPosition, 5));
              },
              onPanUpdate: (details) {
                drawing.addObject(Point(details.localPosition, 5));
              },
              child: FutureBuilder<ui.Image>(
                future: drawing.toImage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RawImage(
                      alignment: Alignment.topLeft,
                      fit: BoxFit.none,
                      image: snapshot.data!,
                      width: drawing.size.width,
                      height: drawing.size.height,
                      filterQuality: FilterQuality.none,
                    );
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
