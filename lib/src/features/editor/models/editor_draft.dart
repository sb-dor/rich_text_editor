class EditorDraft {
  const EditorDraft({
    required this.title,
    required this.html,
    required this.deltaJson,
    required this.savedAt,
  });

  final String title;
  final String html;

  /// Quill `Delta` operations as JSON.
  final List<dynamic> deltaJson;
  final DateTime savedAt;
}
