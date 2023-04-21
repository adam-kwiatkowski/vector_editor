import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_editor/widgets/drawing_widget.dart';
import 'package:vector_editor/widgets/tool_button.dart';

import 'graphics/drawing.dart';
import 'graphics/shapes/converter_utils.dart';
import 'graphics/shapes/shape.dart';

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
            message: 'Save',
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                var json = JsonConverter.toJsonList(drawing.objects);
                String? outputFile = await FilePicker.platform.saveFile(
                  fileName: 'drawing.json',
                  dialogTitle: 'Save drawing as',
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );

                if (outputFile != null) {
                  final file = File(outputFile);
                  file.writeAsString(jsonEncode(json));
                }
              },
            ),
          ),
          Tooltip(
            message: 'Load from file',
            child: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );

                if (result != null) {
                  final file = File(result.files.single.path!);
                  final json = jsonDecode(await file.readAsString());
                  final objects = JsonConverter.fromJsonList(json);
                  // convert from List<Shape?> to List<Shape>
                  final objectsNotNull = objects.whereType<Shape>().toList();
                  setState(() {
                    drawing.objects = objectsNotNull;
                  });
                }
              },
            ),
          ),
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                padding: const EdgeInsets.all(0),
                value: 0,
                checked: drawing.antiAlias,
                child: Text('Antialiasing',
                    style: Theme.of(context).textTheme.labelMedium),
              ),
              PopupMenuItem(
                  value: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    leading: const Icon(null),
                    title: Text('Clear',
                        style: Theme.of(context).textTheme.labelMedium),
                  )),
            ],
            onSelected: (value) {
              if (value == 0) {
                setState(() {
                  drawing.antiAlias = !drawing.antiAlias;
                });
              } else if (value == 1) {
                setState(() {
                  drawing.clear();
                });
              }
            },
          )
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: DrawingWidget(selectedTool))),
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
