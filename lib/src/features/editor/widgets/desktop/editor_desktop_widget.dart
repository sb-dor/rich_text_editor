import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:richtexteditor/src/features/editor/controller/editor_controller.dart';
import 'package:richtexteditor/src/features/editor/widgets/editor_a4_page_widget.dart';
import 'package:richtexteditor/src/features/editor/widgets/editor_config_widget.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class EditorDesktopWidget extends StatefulWidget {
  const EditorDesktopWidget({super.key});

  @override
  State<EditorDesktopWidget> createState() => _EditorDesktopWidgetState();
}

class _EditorDesktopWidgetState extends State<EditorDesktopWidget> {
  late final EditorConfigWidgetState _scope = EditorConfigInhWidget.of(context);

  void _send() {
    final delta = _scope.quillController.document.toDelta().toJson();
    final html = QuillDeltaToHtmlConverter(
      List.castFrom<dynamic, Map<String, dynamic>>(delta),
      ConverterOptions.forEmail(),
    ).convert();
    _scope.editorController.send(html: html, title: _scope.editorDataController.title);
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
            config: const quill.QuillSimpleToolbarConfig(
              showAlignmentButtons: true,
              showFontFamily: false,
              showFontSize: true,
              showSearchButton: false,
              multiRowsDisplay: false,
            ),
          ),
        ),
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
