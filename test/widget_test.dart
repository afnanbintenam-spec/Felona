// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:felo_na/main.dart';
import 'package:felo_na/core/di/injection_container.dart' as di;

void main() {
  testWidgets('App should launch successfully', (WidgetTester tester) async {
    // Initialize dependencies before testing
    await di.initializeDependencies();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const FeloNaApp());

    // Verify that the app launches (splash screen should be visible)
    expect(find.byType(FeloNaApp), findsOneWidget);
    
    // Wait for any pending timers (splash screen navigation)
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
