import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_editor/widgets/drawing_widget.dart';
import 'package:vector_editor/widgets/tool_button.dart';

import 'graphics/drawing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Drawing(const Size(0, 0))),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        home: const MyHomePage(title: 'Vector Painter'),
      ),
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

  @override
  Widget build(BuildContext context) {
    var drawing = context.watch<Drawing>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Tooltip(
            message: 'Antialiasing',
            waitDuration: const Duration(milliseconds: 300),
            child: Checkbox(
              value: drawing.antiAlias,
              onChanged: (value) {
                setState(() {
                  drawing.antiAlias = value!;
                });
              },
            ),
          )
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            const Positioned.fill(
                child: Align(
                    alignment: Alignment.topLeft, child: DrawingWidget())),
            Positioned.fill(
              bottom: 25,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: buildToolbar(context, selectedTool, (tool) {
                  setState(() {
                    selectedTool = tool;
                  });
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
