import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week7/main.dart';

void main() {
  testWidgets('Chromn tab count updates', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Chromn'), findsOneWidget);
    expect(find.byKey(const ValueKey('tabCount')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byTooltip('Open new tab'));
    await tester.pump();

    expect(find.text('4'), findsOneWidget);
  });
}
