import 'dart:ui' as ui;

import 'package:flutter/material.dart';

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
  var tools = [
    {
      'icon': Icons.north_west_outlined,
      'label': 'Move',
    },
    {
      'icon': Icons.shape_line_outlined,
      'label': 'Draw line',
    },
    {
      'icon': Icons.circle_outlined,
      'label': 'Circle',
    },
    {
      'icon': Icons.pentagon_outlined,
      'label': 'Polygon',
    },
  ];
  var selectedTool = 0;

  ui.Image? image;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            GestureDetector(
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final point = box.globalToLocal(details.globalPosition);
                var drawing = Drawing(MediaQuery.of(context).size, [Point(point, 10)]);
                drawing.toImage().then((value) {
                  setState(() {
                    image = value;
                  });
                });
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: RawImage(
                  image: image,
                ),
              ),
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
              for (var i = 0; i < tools.length; i++)
                ToolButton(
                  icon: tools[i]['icon'] as IconData,
                  label: tools[i]['label'] as String,
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

// class MyPainter extends CustomPainter {
//   final Drawing drawing;
//
//   MyPainter(this.drawing);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
//
// }