import 'package:flutter/widgets.dart';
import 'package:richtexteditor/src/features/editor/widgets/editor_config_widget.dart';

/// Top-level entry for the editor route — just hosts the config widget.
class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) => const EditorConfigWidget();
}
