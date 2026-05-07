import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:richtexteditor/src/features/editor/models/editor_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A locally-persisted draft of an in-progress document.

abstract interface class IEditorRepository {
  Future<String> uploadHtml({required String html, String? title});

  Future<void> saveDraft({
    required String title,
    required String html,
    required List<dynamic> deltaJson,
  });

  Future<EditorDraft?> loadDraft();

  Future<bool> hasDraft();

  Future<void> clearDraft();
}

class EditorRepositoryImpl implements IEditorRepository {
  EditorRepositoryImpl({required Dio dio, required SharedPreferences sharedPreferences})
    : _dio = dio,
      _prefs = sharedPreferences;

  final Dio _dio;
  final SharedPreferences _prefs;

  static const _draftKey = 'editor_draft_v1';

  @override
  Future<String> uploadHtml({required String html, String? title}) async {
    final body = <String, Object?>{'title': title ?? 'Untitled', 'html': html};

    l.d('Sending html: $body');

    final response = await _dio.post<Map<String, Object?>>('/api/documents', data: body);
    final data = response.data!;
    return (data['id'] ?? data['url'] ?? '').toString();
  }

  @override
  Future<void> saveDraft({
    required String title,
    required String html,
    required List<dynamic> deltaJson,
  }) async {
    final payload = jsonEncode(<String, Object?>{
      'title': title,
      'html': html,
      'delta': deltaJson,
      'savedAt': DateTime.now().toIso8601String(),
    });
    await _prefs.setString(_draftKey, payload);
  }

  @override
  Future<EditorDraft?> loadDraft() async {
    final raw = _prefs.getString(_draftKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, Object?>;
      return EditorDraft(
        title: (map['title'] ?? '') as String,
        html: (map['html'] ?? '') as String,
        deltaJson: (map['delta'] ?? const <dynamic>[]) as List<dynamic>,
        savedAt: DateTime.tryParse((map['savedAt'] ?? '') as String) ?? DateTime.now(),
      );
    } on Object catch (e, st) {
      l.w('Failed to decode draft: $e\n$st');
      return null;
    }
  }

  @override
  Future<bool> hasDraft() async => _prefs.containsKey(_draftKey);

  @override
  Future<void> clearDraft() async => _prefs.remove(_draftKey);
}

class EditorFakeRepositoryImpl implements IEditorRepository {
  EditorDraft? _draft;

  @override
  Future<String> uploadHtml({required String html, String? title}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return 'fake-id-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> saveDraft({
    required String title,
    required String html,
    required List<dynamic> deltaJson,
  }) async {
    _draft = EditorDraft(title: title, html: html, deltaJson: deltaJson, savedAt: DateTime.now());
  }

  @override
  Future<EditorDraft?> loadDraft() async => _draft;

  @override
  Future<bool> hasDraft() async => _draft != null;

  @override
  Future<void> clearDraft() async => _draft = null;
}
