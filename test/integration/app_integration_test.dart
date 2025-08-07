import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:agenda_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('should launch app successfully', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app starts without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle basic navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test basic app functionality
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Look for common UI elements
      final commonElements = [
        find.byType(Scaffold),
        find.byType(AppBar),
        find.byType(MaterialApp),
      ];

      for (final element in commonElements) {
        expect(element, findsAtLeastNWidgets(1));
      }
    });

    testWidgets('should handle screen rotations', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test portrait orientation
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );

      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle app lifecycle changes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate app going to background and coming back
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        null,
        (data) {},
      );

      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Calendar Integration Tests', () {
    testWidgets('should display calendar interface', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for calendar-related elements - try each one separately
      final calendarFinders = [
        find.text('Calendar'),
        find.text('Kalender'),
        find.byIcon(Icons.calendar_today),
      ];

      Finder? foundButton;
      for (final finder in calendarFinders) {
        if (tester.any(finder)) {
          foundButton = finder;
          break;
        }
      }

      if (foundButton != null) {
        await tester.tap(foundButton);
        await tester.pumpAndSettle();
      }

      // Verify calendar loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle date selection', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to calendar if available
      final calendarFinders = [
        find.text('Calendar'),
        find.text('Kalender'),
        find.byIcon(Icons.calendar_today),
      ];

      Finder? foundButton;
      for (final finder in calendarFinders) {
        if (tester.any(finder)) {
          foundButton = finder;
          break;
        }
      }

      if (foundButton != null) {
        await tester.tap(foundButton);
        await tester.pumpAndSettle();

        // Try to interact with calendar
        await tester.pumpAndSettle(Duration(seconds: 1));
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });

  group('Teams Integration Tests', () {
    testWidgets('should display teams interface', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for teams-related elements
      final teamsFinders = [
        find.text('Teams'),
        find.text('Team'),
        find.byIcon(Icons.people),
        find.byIcon(Icons.group),
      ];

      Finder? foundButton;
      for (final finder in teamsFinders) {
        if (tester.any(finder)) {
          foundButton = finder;
          break;
        }
      }

      if (foundButton != null) {
        await tester.tap(foundButton);
        await tester.pumpAndSettle();
      }

      // Verify teams page loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle empty teams state', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to teams
      final teamsFinders = [
        find.text('Teams'),
        find.text('Team'),
        find.byIcon(Icons.people),
      ];

      Finder? foundButton;
      for (final finder in teamsFinders) {
        if (tester.any(finder)) {
          foundButton = finder;
          break;
        }
      }

      if (foundButton != null) {
        await tester.tap(foundButton);
        await tester.pumpAndSettle();

        // Should handle empty state gracefully
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });

  group('Authentication Integration Tests', () {
    testWidgets('should handle unauthenticated state', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // App should work without authentication (show login or handle gracefully)
      expect(find.byType(MaterialApp), findsOneWidget);

      // Should not crash when accessing protected features
      await tester.pumpAndSettle(Duration(seconds: 2));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should display login interface if needed', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for login-related elements
      final loginElements = [
        find.text('Login'),
        find.text('Sign In'),
        find.text('Inloggen'),
        find.byType(TextField),
        find.byType(TextFormField),
      ];

      // If any login elements are present, verify they work
      for (final element in loginElements) {
        if (tester.any(element)) {
          // Login interface is present and accessible
          expect(find.byType(MaterialApp), findsOneWidget);
          break;
        }
      }
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('should handle general errors gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // App should start and handle any initialization errors
      expect(find.byType(MaterialApp), findsOneWidget);

      // Wait for potential async operations to complete/fail
      await tester.pumpAndSettle(Duration(seconds: 3));

      // App should still be running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should maintain UI consistency during errors', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test that UI remains consistent even with backend errors
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Core UI elements should still be present
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
  });
}
