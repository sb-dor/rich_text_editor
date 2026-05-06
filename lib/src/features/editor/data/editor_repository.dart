import 'package:dio/dio.dart';

abstract interface class IEditorRepository {
  Future<String> uploadHtml({required String html, String? title});
}

class EditorRepositoryImpl implements IEditorRepository {
  EditorRepositoryImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<String> uploadHtml({required String html, String? title}) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/api/documents',
      data: <String, Object?>{'title': title ?? 'Untitled', 'html': html},
    );
    final data = response.data!;
    return (data['id'] ?? data['url'] ?? '').toString();
  }
}

class EditorFakeRepositoryImpl implements IEditorRepository {
  @override
  Future<String> uploadHtml({required String html, String? title}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return 'fake-id-${DateTime.now().millisecondsSinceEpoch}';
  }
}
