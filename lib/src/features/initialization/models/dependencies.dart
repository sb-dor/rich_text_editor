import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:richtexteditor/src/common/model/app_metadata.dart';
import 'package:richtexteditor/src/features/initialization/widget/dependencies_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template dependencies}
/// Application dependencies.
/// {@endtemplate}
class Dependencies {
  /// {@macro dependencies}
  Dependencies();

  /// The state from the closest instance of this class.
  ///
  /// {@macro dependencies}
  factory Dependencies.of(BuildContext context) => DependenciesScope.of(context);

  /// Injest dependencies to the widget tree.
  Widget inject({required Widget child, Key? key}) =>
      DependenciesScope(dependencies: this, key: key, child: child);

  late final SharedPreferences sharedPreferences;

  /// App metadata
  late final AppMetadata metadata;

  /// Shared Dio HTTP client
  late final Dio dio;

  @override
  String toString() => 'Dependencies{}';
}

/// Fake Dependencies
@visibleForTesting
class FakeDependencies extends Dependencies {
  FakeDependencies();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // ... implement fake dependencies
    throw UnimplementedError();
  }
}
