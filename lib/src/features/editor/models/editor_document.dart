import 'package:flutter/foundation.dart';

/// Domain model representing a rich-text document.
/// Holds the Quill Delta JSON (canonical form) plus a title.
@immutable
class EditorDocument {
  const EditorDocument({required this.title, required this.deltaJson});

  final String title;

  /// Quill Delta encoded as JSON-friendly `List<Map<String, Object?>>`.
  final List<Map<String, Object?>> deltaJson;

  EditorDocument copyWith({String? title, List<Map<String, Object?>>? deltaJson}) =>
      EditorDocument(title: title ?? this.title, deltaJson: deltaJson ?? this.deltaJson);
}
