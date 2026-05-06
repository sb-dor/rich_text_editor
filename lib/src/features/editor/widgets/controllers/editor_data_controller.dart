import 'package:flutter/foundation.dart';

/// UI-only state for the editor surface (zoom, document title).
/// Kept separate from [EditorController] which deals with async upload state.
class EditorDataController with ChangeNotifier {
  EditorDataController({String title = 'Untitled', double zoom = 1}) : _title = title, _zoom = zoom;

  String _title;
  double _zoom;

  String get title => _title;
  double get zoom => _zoom;

  void setTitle(String value) {
    if (_title == value) return;
    _title = value;
    notifyListeners();
  }

  void setZoom(double value) {
    final clamped = value.clamp(0.5, 2.5);
    if (_zoom == clamped) return;
    _zoom = clamped;
    notifyListeners();
  }
}
