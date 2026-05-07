import 'package:control/control.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:richtexteditor/src/features/editor/controller/editor_controller.dart';
import 'package:richtexteditor/src/features/editor/util/html_to_docx.dart';
import 'package:richtexteditor/src/features/editor/widgets/editor_a4_page_widget.dart';
import 'package:richtexteditor/src/features/editor/widgets/editor_config_widget.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class EditorMobileWidget extends StatefulWidget {
  const EditorMobileWidget({super.key});

  @override
  State<EditorMobileWidget> createState() => _EditorMobileWidgetState();
}

class _EditorMobileWidgetState extends State<EditorMobileWidget> {
  late final EditorConfigWidgetState _scope = EditorConfigInhWidget.of(context);

  String _buildHtml() {
    final delta = _scope.quillController.document.toDelta().toJson();
    return QuillDeltaToHtmlConverter(
      List.castFrom<dynamic, Map<String, dynamic>>(delta),
      ConverterOptions.forEmail(),
    ).convert();
  }

  void _send() =>
      _scope.editorController.send(html: _buildHtml(), title: _scope.editorDataController.title);

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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft loaded')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF2A2A2A),
    appBar: AppBar(
      title: const Text('Editor'),
      actions: <Widget>[
        IconButton(
          tooltip: 'Save draft',
          icon: const Icon(Icons.save_outlined),
          onPressed: _saveDraft,
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _scope.editorController.hasDraft,
          builder: (context, hasDraft, _) => IconButton(
            tooltip: 'Load draft',
            icon: const Icon(Icons.folder_open_outlined),
            onPressed: hasDraft ? _loadDraft : null,
          ),
        ),
        IconButton(
          tooltip: 'Save as Word',
          icon: const Icon(Icons.description_outlined),
          onPressed: _saveAsWord,
        ),
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
            return IconButton(
              tooltip: inProgress ? 'Sending…' : 'Send',
              onPressed: inProgress ? null : _send,
              icon: inProgress
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
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
            config: const quill.QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: false,
              showSearchButton: false,
              multiRowsDisplay: false,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
        ),
      ],
    ),
  );
}
