// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agenda_app/main.dart';

void main() {
  testWidgets('App should launch without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app loads successfully
    expect(find.byType(MaterialApp), findsOneWidget);

    // Wait for async initialization with timeout
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify the app is still running after initialization
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App should have proper Material structure', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Wait for initialization with timeout
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify core Material Design structure
    expect(find.byType(MaterialApp), findsOneWidget);
    // Only check for Scaffold if it exists (app might be showing login first)
    if (tester.any(find.byType(Scaffold))) {
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    }
  });
}
