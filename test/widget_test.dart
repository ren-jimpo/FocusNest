// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:focus_nest/main.dart';

void main() {
  testWidgets('FocusNest app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FocusNestApp());

    // Verify that our app loads with task screen
    expect(find.text('タスク'), findsOneWidget);
    expect(find.text('学習テーマ'), findsOneWidget);

    // Tap the study themes tab
    await tester.tap(find.text('学習テーマ'));
    await tester.pump();

    // Verify that the themes screen is displayed
    expect(find.text('学習テーマ'), findsWidgets);
  });
}
