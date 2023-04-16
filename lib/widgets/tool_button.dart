import 'package:flutter/material.dart';

import '../graphics/tools.dart';

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

Widget buildToolbar(BuildContext context, int selectedTool,
    Function(int) onSelectedToolChanged) {
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
                onPressed: () => onSelectedToolChanged(i),
              ),
            buildDivider(context),
            ToolButton(
              icon: Icons.color_lens_outlined,
              label: 'Color',
              onPressed: () {},
            ),
            buildDivider(context),
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

Padding buildDivider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
    child: VerticalDivider(
      color: Theme.of(context).colorScheme.outlineVariant,
      width: 1,
      thickness: 1,
    ),
  );
}
