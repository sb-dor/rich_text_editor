import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:richtexteditor/src/common/util/screen_util.dart';
import 'package:richtexteditor/src/features/editor/controller/editor_controller.dart';
import 'package:richtexteditor/src/features/editor/data/editor_repository.dart';
import 'package:richtexteditor/src/features/editor/widgets/controllers/editor_data_controller.dart';
import 'package:richtexteditor/src/features/editor/widgets/desktop/editor_desktop_widget.dart';
import 'package:richtexteditor/src/features/editor/widgets/mobile/editor_mobile_widget.dart';
import 'package:richtexteditor/src/features/initialization/models/dependencies.dart';

/// {@template editor_config_widget}
/// Owns lifecycle of all editor-related controllers (Quill, upload, UI state)
/// and exposes them to descendant widgets via [EditorConfigInhWidget].
/// {@endtemplate}
class EditorConfigWidget extends StatefulWidget {
  /// {@macro editor_config_widget}
  const EditorConfigWidget({super.key});

  @override
  State<EditorConfigWidget> createState() => EditorConfigWidgetState();
}

class EditorConfigWidgetState extends State<EditorConfigWidget> {
  late final quill.QuillController quillController;
  late final FocusNode editorFocusNode;
  late final ScrollController editorScrollController;
  late final EditorController editorController;
  late final EditorDataController editorDataController;

  @override
  void initState() {
    super.initState();
    final dependencies = Dependencies.of(context);

    quillController = quill.QuillController.basic();
    editorFocusNode = FocusNode();
    editorScrollController = ScrollController();
    editorDataController = EditorDataController();
    editorController = EditorController(
      repository: EditorRepositoryImpl(
        dio: dependencies.dio,
        sharedPreferences: dependencies.sharedPreferences,
      ),
    );
    editorController.refreshHasDraft();
  }

  @override
  void dispose() {
    quillController.dispose();
    editorFocusNode.dispose();
    editorScrollController.dispose();
    editorDataController.dispose();
    editorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EditorConfigInhWidget(
    state: this,
    child: context.screenSizeMaybeWhen(
      orElse: () => const EditorDesktopWidget(),
      phone: () => const EditorMobileWidget(),
    ),
  );
}

/// Inherited widget exposing [EditorConfigWidgetState] to descendants.
class EditorConfigInhWidget extends InheritedWidget {
  const EditorConfigInhWidget({required this.state, required super.child, super.key});

  final EditorConfigWidgetState state;

  static EditorConfigWidgetState of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<EditorConfigInhWidget>()?.widget;
    assert(widget != null, 'EditorConfigInhWidget was not found in element tree');
    return (widget! as EditorConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(EditorConfigInhWidget old) => false;
}
