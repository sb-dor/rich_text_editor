import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:richtexteditor/src/features/editor/controller/editor_controller.dart';
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
      title: const Text('Editor'),
      actions: <Widget>[
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
