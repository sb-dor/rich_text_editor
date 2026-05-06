import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// A4 page constants @ 96 DPI.
/// 210 mm × 297 mm  ≈  794 px × 1123 px
class A4 {
  static const double widthPx = 794;
  static const double heightPx = 1123;
  static const double marginPx = 96; // ~1 inch
}

/// Visually mimics a sheet of A4 paper containing a [QuillEditor].
class EditorA4PageWidget extends StatelessWidget {
  const EditorA4PageWidget({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.zoom,
    super.key,
  });

  final quill.QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final page = Container(
      width: A4.widthPx,
      constraints: const BoxConstraints(minHeight: A4.heightPx),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(A4.marginPx),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.4),
        child: quill.QuillEditor.basic(
          controller: controller,
          focusNode: focusNode,
          scrollController: scrollController,
          config: const quill.QuillEditorConfig(
            scrollable: false,
            autoFocus: false,
            expands: false,
            padding: EdgeInsets.zero,
            placeholder: 'Start typing your document…',
          ),
        ),
      ),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Transform.scale(alignment: Alignment.topCenter, scale: zoom, child: page),
      ),
    );
  }
}
