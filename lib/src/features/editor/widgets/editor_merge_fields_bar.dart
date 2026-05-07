import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:richtexteditor/src/features/editor/util/merge_field.dart';

/// Horizontal bar of buttons that insert template placeholders (merge fields)
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Insert field:', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            for (final field in kAvailableMergeFields)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(field.label),
                  onPressed: () => _insert(field),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
