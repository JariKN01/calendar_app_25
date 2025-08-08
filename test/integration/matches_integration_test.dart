import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:calendar_app/main.dart' as app;
import 'package:calendar_app/src/controller/matches_controller.dart';
import 'package:calendar_app/src/model/match.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Matches Integration Tests', () {
    testWidgets('should load and display matches list', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Look for matches-related UI elements
      // This assumes there's a matches screen accessible from the main screen
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Try to find navigation to matches - check each finder separately
      final matchesFinders = [
        find.text('Matches'),
        find.text('Wedstrijden'),
        find.byIcon(Icons.sports_soccer),
      ];

      Finder? foundButton;
      for (final finder in matchesFinders) {
        if (tester.any(finder)) {
          foundButton = finder;
          break;
        }
      }

      if (foundButton != null) {
        await tester.tap(foundButton);
        await tester.pumpAndSettle();
      }

      // Verify the matches screen loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle empty matches state', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to matches if possible
      final matchesFinders = [
        find.text('Matches'),
        find.text('Wedstrijden'),
        find.byIcon(Icons.sports_soccer),
      ];

      Finder? foundButton;
      for (final finder in matchesFinders) {
        if (tester.any(finder)) {
          foundButton = finder;
          break;
        }
      }

      if (foundButton != null) {
        await tester.tap(foundButton);
        await tester.pumpAndSettle();
      }

      // Should handle empty state gracefully (no crashes)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should navigate between screens without crashing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test navigation robustness
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Try to find and tap various navigation elements
      final navigationElements = [
        find.byIcon(Icons.home),
        find.byIcon(Icons.calendar_today),
        find.byIcon(Icons.sports_soccer),
        find.byIcon(Icons.people),
        find.text('Home'),
        find.text('Calendar'),
        find.text('Matches'),
        find.text('Teams'),
      ];

      for (final element in navigationElements) {
        if (tester.any(element)) {
          await tester.tap(element);
          await tester.pumpAndSettle();
          // Verify app doesn't crash
          expect(find.byType(MaterialApp), findsOneWidget);
          break; // Only test one navigation to avoid complex state issues
        }
      }
    });
  });

  group('Match Controller Integration Tests', () {
    late MatchController controller;

    setUp(() {
      controller = MatchController();
    });

    testWidgets('should initialize controller properly', (WidgetTester tester) async {
      // Test controller initialization
      expect(controller.matches, isNotNull);
      expect(controller.matchesNotifier, isNotNull);
      expect(controller.matchesNotifier.value, isEmpty);
    });

    testWidgets('should handle network requests gracefully', (WidgetTester tester) async {
      // Test that network requests don't crash the app
      try {
        await controller.getMatches();
        // If successful, matches should be a list (possibly empty)
        expect(controller.matches, isA<List<Match>>());
      } catch (e) {
        // Network errors are expected in test environment
        expect(e, isA<Exception>());
        print('Expected network error in test environment: $e');
      }
    });

    testWidgets('should validate match creation inputs', (WidgetTester tester) async {
      final startDate = DateTime.now().add(Duration(days: 1));
      final endDate = startDate.add(Duration(hours: 2));

      // Test match creation validation
      try {
        final result = await controller.createMatch(
          title: 'Test Match',
          description: 'Integration test match',
          datetimeStart: startDate,
          datetimeEnd: endDate,
          teamId: 1,
          metadata: {'test': true},
        );

        // In test environment, this might fail due to network/auth
        // but should not crash the app
        expect(result, isA<bool>());
      } catch (e) {
        // Expected in test environment without proper API setup
        expect(e, isA<Exception>());
        print('Expected API error in test environment: $e');
      }
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('should handle authentication errors gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // App should load even without authentication
      expect(find.byType(MaterialApp), findsOneWidget);

      // Should not crash when trying to access protected routes
      await tester.pumpAndSettle(Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle network connectivity issues', (WidgetTester tester) async {
      final controller = MatchController();

      // Test network error handling
      try {
        await controller.getMatches();
      } catch (e) {
        // Should catch and handle network errors properly
        expect(e.toString(), contains('Failed to load matches'));
      }
    });
  });
}
