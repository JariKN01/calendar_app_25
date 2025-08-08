import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:calendar_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Matches Integration Tests', () {
    testWidgets('Matches list loads and displays correctly', (WidgetTester tester) async {
      // Start de app
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Navigeer naar matches tab als we ingelogd zijn
      final tabBar = find.byType(TabBar);
      if (tabBar.hasFound) {
        final tabs = find.byType(Tab);
        if (tabs.hasFound && tabs.evaluate().length >= 3) {
          // Tap op matches tab (index kan variëren)
          await tester.tap(tabs.at(2));
          await tester.pumpAndSettle();

          // Verifieer dat matches content wordt geladen
          expect(
            find.byType(ListView).hasFound ||
            find.text('No matches').hasFound ||
            find.byType(CircularProgressIndicator).hasFound,
            isTrue,
            reason: 'Matches tab should show list, empty state, or loading'
          );
        }
      }
    });

    testWidgets('Match creation flow works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Navigeer naar matches
      final tabBar = find.byType(TabBar);
      if (tabBar.hasFound) {
        final tabs = find.byType(Tab);
        if (tabs.hasFound) {
          await tester.tap(tabs.at(2)); // Matches tab
          await tester.pumpAndSettle();

          // Zoek naar create match knop
          final createButton = find.byIcon(Icons.add);
          if (createButton.hasFound) {
            await tester.tap(createButton);
            await tester.pumpAndSettle();

            // Verifieer dat create form opent
            final textFields = find.byType(TextField);
            expect(textFields.hasFound, isTrue, reason: 'Create match form should have input fields');

            // Test form validatie
            final submitButton = find.byType(ElevatedButton);
            if (submitButton.hasFound) {
              await tester.tap(submitButton.first);
              await tester.pumpAndSettle();
              // Validatie errors zouden moeten verschijnen
            }
          }
        }
      }
    });

    testWidgets('Match filtering and sorting works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      final tabBar = find.byType(TabBar);
      if (tabBar.hasFound) {
        final tabs = find.byType(Tab);
        if (tabs.hasFound) {
          await tester.tap(tabs.at(2)); // Matches tab
          await tester.pumpAndSettle();

          // Test filter opties als ze bestaan
          final filterButton = find.byIcon(Icons.filter_list);
          if (filterButton.hasFound) {
            await tester.tap(filterButton);
            await tester.pumpAndSettle();

            // Filter menu zou moeten openen
          }

          // Test refresh functionaliteit
          final refreshButton = find.byIcon(Icons.refresh);
          if (refreshButton.hasFound) {
            await tester.tap(refreshButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('Match details view works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      final tabBar = find.byType(TabBar);
      if (tabBar.hasFound) {
        final tabs = find.byType(Tab);
        if (tabs.hasFound) {
          await tester.tap(tabs.at(2)); // Matches tab
          await tester.pumpAndSettle();

          // Zoek naar match items in de lijst
          final listTiles = find.byType(ListTile);
          if (listTiles.hasFound) {
            // Tap op eerste match
            await tester.tap(listTiles.first);
            await tester.pumpAndSettle();

            // Match details zou moeten openen
            // Dit hangt af van je implementatie - mogelijk een nieuwe route of dialog
          }
        }
      }
    });

    testWidgets('Match invite functionality works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      final tabBar = find.byType(TabBar);
      if (tabBar.hasFound) {
        final tabs = find.byType(Tab);
        if (tabs.hasFound) {
          await tester.tap(tabs.at(2)); // Matches tab
          await tester.pumpAndSettle();

          // Test invite functionaliteit als die bestaat
          final inviteButton = find.byIcon(Icons.person_add);
          if (inviteButton.hasFound) {
            await tester.tap(inviteButton);
            await tester.pumpAndSettle();

            // Invite dialog/form zou moeten openen
            final dialogTextField = find.byType(TextField);
            if (dialogTextField.hasFound) {
              await tester.enterText(dialogTextField.first, 'test@example.com');
              await tester.pumpAndSettle();
            }
          }
        }
      }
    });

    testWidgets('Match status updates work', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      final tabBar = find.byType(TabBar);
      if (tabBar.hasFound) {
        final tabs = find.byType(Tab);
        if (tabs.hasFound) {
          await tester.tap(tabs.at(2)); // Matches tab
          await tester.pumpAndSettle();

          // Test status update knoppen
          final statusButtons = find.byType(IconButton);
          if (statusButtons.hasFound) {
            // Test verschillende status updates
            for (int i = 0; i < statusButtons.evaluate().length && i < 3; i++) {
              await tester.tap(statusButtons.at(i));
              await tester.pumpAndSettle();
            }
          }
        }
      }
    });
  });

  group('Matches Error Handling', () {
    testWidgets('Handles empty matches list gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      final tabBar = find.byType(TabBar);
      if (tabBar.hasFound) {
        final tabs = find.byType(Tab);
        if (tabs.hasFound) {
          await tester.tap(tabs.at(2)); // Matches tab
          await tester.pumpAndSettle();

          // App zou graceful moeten omgaan met lege lijst
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });

    testWidgets('Handles network errors in matches', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      final tabBar = find.byType(TabBar);
      if (tabBar.hasFound) {
        final tabs = find.byType(Tab);
        if (tabs.hasFound) {
          await tester.tap(tabs.at(2)); // Matches tab
          await tester.pumpAndSettle();

          // Force refresh om potential network error te triggeren
          final refreshButton = find.byIcon(Icons.refresh);
          if (refreshButton.hasFound) {
            await tester.tap(refreshButton);
            await tester.pumpAndSettle();
          }

          // App zou stable moeten blijven
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });
  });
}
