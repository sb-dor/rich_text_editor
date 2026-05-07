import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:richtexteditor/src/features/editor/util/merge_field.dart';

/// Single dropdown button that inserts template placeholders (merge fields)
/// at the current cursor position. Inserted as plain unstyled text so any
/// downstream replacement (server template engine etc.) doesn't accidentally
/// inherit editor styling on the substituted value.
class EditorMergeFieldsBar extends StatelessWidget {
  const EditorMergeFieldsBar({required this.controller, super.key});

  final quill.QuillController controller;

  void _insert(MergeField field) {
    final selection = controller.selection;
    // The document always has at least one trailing newline, so length-1 is
    // the highest insertable index.
    final maxIndex = controller.document.length - 1;
    final index = selection.baseOffset.clamp(0, maxIndex);
    final length = (selection.extentOffset - selection.baseOffset).clamp(0, maxIndex - index);

    final placeholder = field.placeholder;
    controller.replaceText(
      index,
      length,
      placeholder,
      TextSelection.collapsed(offset: index + placeholder.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          children: <Widget>[
            PopupMenuButton<MergeField>(
              tooltip: 'Insert template field',
              onSelected: _insert,
              position: PopupMenuPosition.under,
              itemBuilder: (context) => <PopupMenuEntry<MergeField>>[
                for (final field in kAvailableMergeFields)
                  PopupMenuItem<MergeField>(
                    value: field,
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.tag, size: 16),
                        const SizedBox(width: 8),
                        Text(field.label),
                        // const SizedBox(width: 12),
                        // Text(
                        //   field.placeholder,
                        //   style: TextStyle(
                        //     color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        //     fontFamily: 'monospace',
                        //     fontSize: 12,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
              ],
              child: OutlinedButton.icon(
                onPressed: null, // PopupMenuButton handles the tap
                icon: const Icon(Icons.add, size: 16),
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Insert field'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  disabledForegroundColor: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
