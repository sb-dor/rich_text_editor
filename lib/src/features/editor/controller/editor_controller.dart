import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:richtexteditor/src/features/editor/data/editor_repository.dart';

@immutable
sealed class EditorState {
  const EditorState();

  const factory EditorState.idle() = Editor$IdleState;

  const factory EditorState.inProgress() = Editor$InProgressState;

  const factory EditorState.completed(String documentId) = Editor$CompletedState;

  const factory EditorState.error(String? message) = Editor$ErrorState;

  String? get error => switch (this) {
    final Editor$ErrorState s => s.message,
    _ => null,
  };
}

final class Editor$IdleState extends EditorState {
  const Editor$IdleState();
}

final class Editor$InProgressState extends EditorState {
  const Editor$InProgressState();
}

final class Editor$CompletedState extends EditorState {
  const Editor$CompletedState(this.documentId);

  final String documentId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Editor$CompletedState && documentId == other.documentId);

  @override
  int get hashCode => documentId.hashCode;
}

final class Editor$ErrorState extends EditorState {
  const Editor$ErrorState(this.message);

  final String? message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Editor$ErrorState && message == other.message);

  @override
  int get hashCode => message.hashCode;
}

/// Manages the upload lifecycle of a rich-text document.
/// Mutation-style controller — uses [DroppableControllerHandler] so rapid
/// re-taps on "Send" while an upload is in flight are dropped.
class EditorController extends StateController<EditorState> with DroppableControllerHandler {
  EditorController({
    required IEditorRepository repository,
    super.initialState = const EditorState.idle(),
  }) : _repository = repository;

  final IEditorRepository _repository;

  /// Reactive flag — true when a draft exists in local storage.
  /// UI should listen and disable / enable the "Load" button accordingly.
  final ValueNotifier<bool> hasDraft = ValueNotifier<bool>(false);

  void send({required String html, String? title}) => handle(() async {
    setState(const EditorState.inProgress());
    final id = await _repository.uploadHtml(html: html, title: title);
    setState(EditorState.completed(id));
  }, error: (e, st) async => setState(EditorState.error(e.toString())));

  void reset() => setState(const EditorState.idle());

  /// Persist the editor's current document locally. Returns when stored.
  Future<void> saveDraft({
    required String title,
    required String html,
    required List<dynamic> deltaJson,
  }) async {
    await _repository.saveDraft(title: title, html: html, deltaJson: deltaJson);
    hasDraft.value = true;
  }

  /// Read the stored draft (if any). Caller is responsible for applying the
  /// returned [EditorDraft.deltaJson] to the [QuillController].
  Future<EditorDraft?> loadDraft() => _repository.loadDraft();

  /// Refresh [hasDraft] — call once at startup so the UI reflects whether
  /// there's anything to load.
  Future<void> refreshHasDraft() async => hasDraft.value = await _repository.hasDraft();

  Future<void> clearDraft() async {
    await _repository.clearDraft();
    hasDraft.value = false;
  }

  @override
  void dispose() {
    hasDraft.dispose();
    super.dispose();
  }
}
