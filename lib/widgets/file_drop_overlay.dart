import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class FileDropOverlay extends StatefulWidget {
  const FileDropOverlay({Key? key, required this.onDrop, required this.child})
      : super(key: key);

  @override
  FileDropOverlayState createState() => FileDropOverlayState();

  final Function(File) onDrop;
  final Widget child;
}

class FileDropOverlayState extends State<FileDropOverlay> {
  XFile? _file;
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
      onDragDone: (details) {
        setState(() {
          _file = details.files.first;
          if (_file != null && _file!.path.endsWith('.json')) {
            widget.onDrop(File(_file!.path));
          }
          _isDragging = false;
        });
      },
      child: Stack(
        children: [
          widget.child,
          if (_isDragging)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Text(
                  'Drop file here',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
