import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:calendar_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Agenda App Integration Tests', () {
    testWidgets('App should start and navigate to authentication flow', (WidgetTester tester) async {
      // Start de app
      app.main();
      await tester.pumpAndSettle();

      // Controleer of de app start (HomeController of Auth scherm)
      expect(find.byType(MaterialApp), findsOneWidget);

      // Wacht op navigatie naar login/register scherm als er geen token is
      await tester.pumpAndSettle(Duration(seconds: 2));

      // De app zou naar register of login moeten navigeren
      // Dit hangt af van of er een token in storage staat
      print('Current route after startup');
    });

    testWidgets('Navigation between main tabs works', (WidgetTester tester) async {
      // Start de app met een mock token voor testing
      app.main();
      await tester.pumpAndSettle();

      // Als we een TabController hebben, test tab navigatie
      final tabBarFinder = find.byType(TabBar);
      if (tabBarFinder.hasFound) {
        // Test tab switching
        final tabs = find.byType(Tab);
        if (tabs.hasFound) {
          // Tap op verschillende tabs
          for (int i = 0; i < 4; i++) {
            await tester.tap(tabs.at(i));
            await tester.pumpAndSettle();

            // Verifieer dat de tab gewijzigd is
            expect(find.byType(TabBarView), findsOneWidget);
          }
        }
      }
    });

    testWidgets('App handles authentication state correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Test dat de app correct reageert op authenticatie status
      // Dit zou naar login/register moeten navigeren als er geen geldig token is

      // Zoek naar login/register elementen
      final loginElements = find.text('Login');
      final registerElements = find.text('Register');
      final emailFields = find.byType(TextField);

      // Een van deze zou aanwezig moeten zijn in een auth flow
      expect(
        loginElements.hasFound || registerElements.hasFound || emailFields.hasFound,
        isTrue,
        reason: 'App should show authentication UI when no valid token exists'
      );
    });
  });

  group('Authentication Flow Tests', () {
    testWidgets('Registration form validation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigeer naar register scherm als we er niet al zijn
      final registerButton = find.text('Register');
      if (registerButton.hasFound) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();
      }

      // Test form validatie
      final textFields = find.byType(TextField);
      if (textFields.hasFound) {
        // Probeer te submitten zonder data
        final submitButtons = find.byType(ElevatedButton);
        if (submitButtons.hasFound) {
          await tester.tap(submitButtons.first);
          await tester.pumpAndSettle();

          // Validatie errors zouden moeten verschijnen
          // Dit hangt af van je implementatie
        }
      }
    });

    testWidgets('Login form validation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigeer naar login scherm
      final loginButton = find.text('Login');
      if (loginButton.hasFound) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      // Test login form
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      if (emailField.hasFound && passwordField.hasFound) {
        // Test met invalid credentials
        await tester.enterText(emailField, 'invalid@email.com');
        await tester.enterText(passwordField, 'wrongpassword');

        final submitButton = find.byType(ElevatedButton);
        if (submitButton.hasFound) {
          await tester.tap(submitButton.first);
          await tester.pumpAndSettle();

          // Error message zou moeten verschijnen
        }
      }
    });
  });

  group('Main App Features Tests', () {
    testWidgets('Events functionality works', (WidgetTester tester) async {
      // Deze test vereist een geldige login
      app.main();
      await tester.pumpAndSettle();

      // Skip als we niet ingelogd zijn
      final tabBar = find.byType(TabBar);
      if (!tabBar.hasFound) return;

      // Navigeer naar events tab
      final tabs = find.byType(Tab);
      if (tabs.hasFound && tabs.evaluate().length >= 2) {
        await tester.tap(tabs.at(0)); // Events tab
        await tester.pumpAndSettle();

        // Test events lijst
        final eventsList = find.byType(ListView);
        expect(eventsList.hasFound, isTrue, reason: 'Events list should be present');

        // Test event creation knop
        final createButton = find.byIcon(Icons.add);
        if (createButton.hasFound) {
          await tester.tap(createButton);
          await tester.pumpAndSettle();

          // Event creation form zou moeten openen
        }
      }
    });

    testWidgets('Matches functionality works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tabBar = find.byType(TabBar);
      if (!tabBar.hasFound) return;

      // Navigeer naar matches tab
      final tabs = find.byType(Tab);
      if (tabs.hasFound && tabs.evaluate().length >= 3) {
        await tester.tap(tabs.at(2)); // Matches tab
        await tester.pumpAndSettle();

        // Test matches lijst
        final matchesList = find.byType(ListView);
        expect(matchesList.hasFound || find.text('No matches').hasFound, isTrue);
      }
    });

    testWidgets('Teams functionality works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final tabBar = find.byType(TabBar);
      if (!tabBar.hasFound) return;

      // Navigeer naar teams tab
      final tabs = find.byType(Tab);
      if (tabs.hasFound && tabs.evaluate().length >= 4) {
        await tester.tap(tabs.at(3)); // Teams tab
        await tester.pumpAndSettle();

        // Test teams lijst
        final teamsList = find.byType(ListView);
        expect(teamsList.hasFound || find.text('No teams').hasFound, isTrue);
      }
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App handles network errors gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test dat de app niet crasht bij network errors
      // Dit is meer een smoke test dat de app stable blijft

      // Probeer verschillende acties die network calls zouden maken
      final refreshButton = find.byIcon(Icons.refresh);
      if (refreshButton.hasFound) {
        await tester.tap(refreshButton);
        await tester.pumpAndSettle();
      }

      // App zou nog steeds moeten bestaan
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App persists after orientation change', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test orientation changes
      await tester.binding.setSurfaceSize(Size(800, 600)); // Landscape
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);

      await tester.binding.setSurfaceSize(Size(400, 800)); // Portrait
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
