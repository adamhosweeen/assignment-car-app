import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assignment/views/dev/design_demo_screen.dart';
import 'package:assignment/utils/app_theme.dart';

void main() {
  testWidgets('Design demo renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const DesignDemoScreen()),
    );

    expect(find.text('Design System'), findsOneWidget);
  });
}
