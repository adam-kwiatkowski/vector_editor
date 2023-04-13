import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_editor/graphics/tools.dart';

import 'graphics/drawing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const MyHomePage(title: 'Vector Painter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedTool = 0;

  ui.Image? image;
  Drawing drawing = Drawing(const Size(100, 100), objects: [
    Point(const Offset(20, 20), 10),
    Point(const Offset(80, 80), 10),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            RepaintBoundary(
              child: GestureDetector(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CustomPaint(
                    painter: DrawingPainter(drawing),
                  ),
                ),
              )
            ),
            Positioned.fill(
              bottom: 25,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: buildToolbar(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToolbar(BuildContext context) {
    return Container(
        height: 58,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: -8,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < presetTools.length; i++)
                ToolButton(
                  icon: presetTools[i].icon,
                  label: presetTools[i].name,
                  selected: i == selectedTool,
                  onPressed: () {
                    setState(() {
                      selectedTool = i;
                    });
                  },
                ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: VerticalDivider(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                  thickness: 1,
                ),
              ),
              ToolButton(
                icon: Icons.color_lens_outlined,
                label: 'Color',
                onPressed: () {},
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: VerticalDivider(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                  thickness: 1,
                ),
              ),
              ToolButton(
                icon: Icons.undo_outlined,
                label: 'Undo',
                onPressed: () {},
              ),
              ToolButton(
                icon: Icons.redo_outlined,
                label: 'Redo',
                onPressed: () {},
              ),
            ],
          ),
        ));
  }
}

class DrawingPainter extends CustomPainter {
  final Drawing drawing;

  DrawingPainter(this.drawing);

  @override
  void paint(Canvas canvas, Size size) {
    drawing.size = size;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}

class ToolButton extends StatelessWidget {
  const ToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 300),
        child: Column(
          children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                isSelected: selected,
                onPressed: onPressed,
                icon: Icon(icon),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

