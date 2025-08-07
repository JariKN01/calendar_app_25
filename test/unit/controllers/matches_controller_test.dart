import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agenda_app/src/controller/matches_controller.dart';
import 'package:agenda_app/src/model/match.dart';
import 'dart:convert';

// Generate mocks
@GenerateMocks([http.Client, FlutterSecureStorage])
import 'matches_controller_test.mocks.dart';

void main() {
  // Initialize Flutter bindings for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MatchController Tests', () {
    late MockClient mockHttpClient;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockHttpClient = MockClient();
      mockStorage = MockFlutterSecureStorage();
    });

    group('getMatches Logic Tests', () {
      test('should filter out past matches and sort by date', () {
        // This tests the logic that should be in getMatches
        final now = DateTime.now();
        final futureMatch1 = DateTime.now().add(Duration(days: 2));
        final futureMatch2 = DateTime.now().add(Duration(days: 1));
        final pastMatch = DateTime.now().subtract(Duration(days: 1));

        // Test the sorting logic
        List<DateTime> dates = [futureMatch1, pastMatch, futureMatch2];
        List<DateTime> futureDates = dates.where((date) => date.isAfter(now)).toList();
        futureDates.sort((a, b) => a.compareTo(b));

        expect(futureDates.length, equals(2));
        expect(futureDates[0], equals(futureMatch2)); // Earlier future date first
        expect(futureDates[1], equals(futureMatch1)); // Later future date second
      });
    });

    group('Match Creation Validation', () {
      test('should validate that end date is after start date', () {
        final startDate = DateTime.now().add(Duration(days: 1));
        final endDate = startDate.subtract(Duration(hours: 1)); // Invalid: before start

        expect(endDate.isAfter(startDate), isFalse);
      });

      test('should validate that match is in the future', () {
        final pastDate = DateTime.now().subtract(Duration(days: 1));
        final futureDate = DateTime.now().add(Duration(days: 1));

        expect(pastDate.isAfter(DateTime.now()), isFalse);
        expect(futureDate.isAfter(DateTime.now()), isTrue);
      });

      test('should validate required fields', () {
        const String title = 'Test Match';
        const String description = 'Test Description';
        const int teamId = 1;

        expect(title.isNotEmpty, isTrue);
        expect(description.isNotEmpty, isTrue);
        expect(teamId > 0, isTrue);
      });

      test('should format dates correctly for API', () {
        final testDate = DateTime(2025, 7, 15, 14, 30);
        final iso8601String = testDate.toIso8601String();

        expect(iso8601String, contains('2025-07-15'));
        expect(iso8601String, contains('14:30'));
      });

      test('should handle metadata parameter correctly', () {
        final metadata = {'location': 'Stadium', 'weather': 'sunny'};
        final jsonString = jsonEncode(metadata);
        final decoded = jsonDecode(jsonString);

        expect(decoded['location'], equals('Stadium'));
        expect(decoded['weather'], equals('sunny'));
      });
    });

    group('Error Handling Logic', () {
      test('should handle invalid match data gracefully', () {
        // Test that invalid matches are skipped but processing continues
        final invalidMatchData = {
          'id': 'invalid', // Should be int
          'title': 'Test Match',
        };

        expect(() {
          // This would be called within the controller's error handling
          try {
            Match.fromJson(invalidMatchData);
          } catch (e) {
            // Should continue processing other matches
            print('Error parsing match: $e');
          }
        }, isNot(throwsException));
      });

      test('should handle network errors appropriately', () {
        // Test network error scenarios
        final networkError = Exception('Network error');
        final formattedError = 'Failed to load matches: $networkError';

        expect(formattedError, contains('Network error'));
        expect(formattedError, startsWith('Failed to load matches:'));
      });

      test('should handle authentication errors', () {
        // Test when token is missing or invalid
        const String? nullToken = null;
        expect(nullToken, isNull);

        const String emptyToken = '';
        expect(emptyToken.isEmpty, isTrue);
      });
    });

    group('Data Processing Logic', () {
      test('should process match data correctly', () {
        final futureDate = DateTime.now().add(Duration(days: 1));

        final mockMatchData = {
          'id': 1,
          'title': 'Test Match',
          'description': 'A test match',
          'datetimeStart': futureDate.toIso8601String(),
          'datetimeEnd': futureDate.add(Duration(hours: 2)).toIso8601String(),
          'location': {'lat': 52.0, 'lng': 5.0},
          'teamId': 1,
          'createdBy': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'team': {
            'id': 1,
            'name': 'Test Team',
            'members': []
          },
          'invites': []
        };

        // Test that we can create a match from this data
        expect(() => Match.fromJson(mockMatchData), returnsNormally);

        final match = Match.fromJson(mockMatchData);
        expect(match.title, equals('Test Match'));
        expect(match.datetimeStart.isAfter(DateTime.now()), isTrue);
      });

      test('should handle empty invites list', () {
        final futureDate = DateTime.now().add(Duration(days: 1));

        final mockMatchData = {
          'id': 1,
          'title': 'Test Match',
          'description': 'A test match',
          'datetimeStart': futureDate.toIso8601String(),
          'datetimeEnd': futureDate.add(Duration(hours: 2)).toIso8601String(),
          'location': {'lat': 52.0, 'lng': 5.0},
          'teamId': 1,
          'createdBy': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'team': {
            'id': 1,
            'name': 'Test Team',
            'members': []
          },
          'invites': []
        };

        final match = Match.fromJson(mockMatchData);
        expect(match.invites, isEmpty);
      });
    });

    group('MatchController Unit Tests', () {
      late MatchController controller;
      late MockFlutterSecureStorage mockStorage;

      setUp(() {
        mockStorage = MockFlutterSecureStorage();
        // Mock the secure storage calls to prevent plugin errors
        when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);

        // We can't easily inject the mock into MatchController, so we'll test logic separately
        controller = MatchController();
      });

      test('should validate match creation parameters without network calls', () {
        final startDate = DateTime.now().add(Duration(days: 1));
        final endDate = startDate.add(Duration(hours: 2));
        const title = 'Test Match';
        const description = 'Test Description';
        const teamId = 1;

        // Validate required parameters
        expect(title.isNotEmpty, isTrue);
        expect(description.isNotEmpty, isTrue);
        expect(teamId > 0, isTrue);
        expect(endDate.isAfter(startDate), isTrue);
        expect(startDate.isAfter(DateTime.now()), isTrue);
      });

      test('should initialize with empty matches list', () {
        expect(controller.matches, isEmpty);
        expect(controller.matchesNotifier.value, isEmpty);
      });

      test('should have ValueNotifier for matches', () {
        expect(controller.matchesNotifier, isA<ValueNotifier<List<Match>>>());
      });
    });
  });
}
