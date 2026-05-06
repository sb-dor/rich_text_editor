import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:richtexteditor/src/common/router/routes.dart';

/// {@template home_screen}
/// Home — landing page with shortcuts to the rich-text editor.
/// {@endtemplate}
class HomeScreen extends StatelessWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Home')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.description_outlined, size: 96, color: Colors.teal),
          const SizedBox(height: 16),
          const Text(
            'Rich Text Editor',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.edit_document),
            label: const Text('Open editor'),
            onPressed: () => context.octopus.push(Routes.editor),
          ),
        ],
      ),
    ),
  );
}
