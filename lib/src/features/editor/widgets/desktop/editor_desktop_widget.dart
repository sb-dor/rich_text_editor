import 'dart:io';

import 'package:control/control.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:richtexteditor/src/features/editor/controller/editor_controller.dart';
import 'package:richtexteditor/src/features/editor/util/html_to_docx.dart';
import 'package:richtexteditor/src/features/editor/widgets/editor_a4_page_widget.dart';
import 'package:richtexteditor/src/features/editor/widgets/editor_config_widget.dart';
import 'package:richtexteditor/src/features/editor/widgets/editor_merge_fields_bar.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class EditorDesktopWidget extends StatefulWidget {
  const EditorDesktopWidget({super.key});

  @override
  State<EditorDesktopWidget> createState() => _EditorDesktopWidgetState();
}

/// Numeric font-size dropdown values, 9 → 40 px (plus a clear option).
final Map<String, String> _fontSizeItems = <String, String>{
  for (var px = 9; px <= 40; px++) '$px': '$px',
  'Clear': '0',
};

class _EditorDesktopWidgetState extends State<EditorDesktopWidget> {
  late final EditorConfigWidgetState _scope = EditorConfigInhWidget.of(context);

  String _buildHtml() {
    final delta = _scope.quillController.document.toDelta().toJson();
    return QuillDeltaToHtmlConverter(
      List.castFrom<Object?, Map<String, Object?>>(delta),
      ConverterOptions.forEmail(),
    ).convert();
  }

  void _send() =>
      _scope.editorController.send(html: _buildHtml(), title: _scope.editorDataController.title);

  Future<void> _openInWord() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Opening files is not supported on web')));
      return;
    }
    final bytes = HtmlToDocx.build(_buildHtml());
    final name = _scope.editorDataController.title.trim().isEmpty
        ? 'document'
        : _scope.editorDataController.title.trim();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$name.docx');
    await file.writeAsBytes(bytes, flush: true);

    final result = await OpenFilex.open(file.path);
    if (!mounted) return;
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open: ${result.message}')));
    }
  }

  Future<void> _saveAsWord() async {
    final bytes = HtmlToDocx.build(_buildHtml());
    final name = _scope.editorDataController.title.trim().isEmpty
        ? 'document'
        : _scope.editorDataController.title.trim();
    final saved = await FileSaver.instance.saveAs(
      name: name,
      bytes: bytes,
      ext: 'docx',
      mimeType: MimeType.microsoftWord,
    );
    if (!mounted) return;
    if (saved == null) return; // user cancelled the save dialog
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: $saved')));
  }

  Future<void> _saveDraft() async {
    final delta = _scope.quillController.document.toDelta().toJson();
    await _scope.editorController.saveDraft(
      title: _scope.editorDataController.title,
      html: _buildHtml(),
      deltaJson: delta,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved')));
  }

  Future<void> _loadDraft() async {
    final draft = await _scope.editorController.loadDraft();
    if (!mounted) return;
    if (draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No saved draft')));
      return;
    }
    _scope.quillController.document = quill.Document.fromJson(draft.deltaJson);
    _scope.editorDataController.setTitle(draft.title);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Loaded draft from ${draft.savedAt}')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF2A2A2A),
    appBar: AppBar(
      title: ListenableBuilder(
        listenable: _scope.editorDataController,
        builder: (context, _) => _TitleField(
          initial: _scope.editorDataController.title,
          onChanged: _scope.editorDataController.setTitle,
        ),
      ),
      actions: <Widget>[
        ListenableBuilder(
          listenable: _scope.editorDataController,
          builder: (context, _) => Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Zoom out',
                icon: const Icon(Icons.zoom_out),
                onPressed: () =>
                    _scope.editorDataController.setZoom(_scope.editorDataController.zoom - 0.1),
              ),
              Text('${(_scope.editorDataController.zoom * 100).round()}%'),
              IconButton(
                tooltip: 'Zoom in',
                icon: const Icon(Icons.zoom_in),
                onPressed: () =>
                    _scope.editorDataController.setZoom(_scope.editorDataController.zoom + 0.1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton.icon(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save'),
          ),
        ),
        const SizedBox(width: 4),
        ValueListenableBuilder<bool>(
          valueListenable: _scope.editorController.hasDraft,
          builder: (context, hasDraft, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton.icon(
              onPressed: hasDraft ? _loadDraft : null,
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Load'),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton.icon(
            onPressed: _saveAsWord,
            icon: const Icon(Icons.description_outlined),
            label: const Text('Save as Word'),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton.icon(
            onPressed: _openInWord,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in Word'),
          ),
        ),
        const SizedBox(width: 8),
        StateConsumer<EditorController, EditorState>(
          controller: _scope.editorController,
          listener: (context, controller, oldState, newState) {
            if (newState is Editor$CompletedState) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Sent. Document id: ${newState.documentId}')));
              controller.reset();
            } else if (newState is Editor$ErrorState) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(newState.message ?? 'Upload failed')));
            }
          },
          builder: (context, state, _) {
            final inProgress = state is Editor$InProgressState;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FilledButton.icon(
                onPressed: inProgress ? null : _send,
                icon: inProgress
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(inProgress ? 'Sending…' : 'Send'),
              ),
            );
          },
        ),
      ],
    ),
    body: Column(
      children: <Widget>[
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: quill.QuillSimpleToolbar(
            controller: _scope.quillController,
            config: quill.QuillSimpleToolbarConfig(
              showAlignmentButtons: true,
              showFontFamily: false,
              showFontSize: true,
              showSearchButton: false,
              multiRowsDisplay: false,
              buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                fontSize: quill.QuillToolbarFontSizeButtonOptions(items: _fontSizeItems),
              ),
            ),
          ),
        ),
        EditorMergeFieldsBar(controller: _scope.quillController),
        Expanded(
          child: SingleChildScrollView(
            child: ListenableBuilder(
              listenable: _scope.editorDataController,
              builder: (context, _) => EditorA4PageWidget(
                controller: _scope.quillController,
                focusNode: _scope.editorFocusNode,
                scrollController: _scope.editorScrollController,
                zoom: _scope.editorDataController.zoom,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _TitleField extends StatefulWidget {
  const _TitleField({required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_TitleField> createState() => _TitleFieldState();
}

class _TitleFieldState extends State<_TitleField> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 320,
    child: TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Document title'),
    ),
  );
}
