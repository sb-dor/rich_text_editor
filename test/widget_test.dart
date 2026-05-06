import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:richtexteditor/src/features/initialization/models/dependencies.dart';
import 'package:richtexteditor/src/features/initialization/widget/dependencies_scope.dart';

void main() => group('Widget', () {
  testWidgets('Dependencies_are_injected', (tester) async {
    await tester.pumpWidget(FakeDependencies().inject(child: Container()));
    expect(find.byType(Container), findsOneWidget);
    expect(find.byType(DependenciesScope), findsOneWidget);
    final context = tester.element(find.byType(Container));
    expect(
      Dependencies.of(context),
      allOf(isNotNull, isA<Dependencies>(), isA<FakeDependencies>()),
    );
  });
});
