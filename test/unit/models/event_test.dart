import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/src/model/event.dart';
import 'package:calendar_app/src/model/team.dart';
import 'package:calendar_app/src/model/user.dart';

void main() {
  group('Event Model Tests', () {
    late Map<String, dynamic> validEventJson;
    late DateTime testStartDate;
    late DateTime testEndDate;
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;

    setUp(() {
      testStartDate = DateTime(2025, 7, 15, 10, 0);
      testEndDate = DateTime(2025, 7, 15, 12, 0);
      testCreatedAt = DateTime(2025, 7, 1, 9, 0);
      testUpdatedAt = DateTime(2025, 7, 10, 14, 30);

      validEventJson = {
        'id': 1,
        'title': 'Team Meeting',
        'description': 'Weekly team sync meeting',
        'datetimeStart': testStartDate.toIso8601String(),
        'datetimeEnd': testEndDate.toIso8601String(),
        'location': {'lat': 52.0907, 'lng': 5.1214},
        'teamId': 1,
        'createdBy': 1,
        'createdAt': testCreatedAt.toIso8601String(),
        'updatedAt': testUpdatedAt.toIso8601String(),
        'team': {
          'id': 1,
          'name': 'Development Team',
          'description': 'Software development team',
          'ownerId': 1,
          'createdAt': testCreatedAt.toIso8601String(),
          'updatedAt': testUpdatedAt.toIso8601String(),
          'metadata': {'icon': 'work'},
          'members': [
            {
              'id': 1,
              'name': 'John Doe',
            }
          ]
        },
        'invites': []
      };
    });

    test('should create Event from valid JSON', () {
      final event = Event.fromJson(validEventJson);

      expect(event.id, equals(1));
      expect(event.title, equals('Team Meeting'));
      expect(event.description, equals('Weekly team sync meeting'));
      expect(event.datetimeStart, equals(testStartDate));
      expect(event.datetimeEnd, equals(testEndDate));
      expect(event.location, equals({'lat': 52.0907, 'lng': 5.1214}));
      expect(event.teamId, equals(1));
      expect(event.createdBy, equals(1));
      expect(event.createdAt, equals(testCreatedAt));
      expect(event.updatedAt, equals(testUpdatedAt));
      expect(event.team.name, equals('Development Team'));
      expect(event.invites, isNotNull);
      expect(event.invites!.length, equals(0));
    });

    test('should create Event with null location', () {
      validEventJson['location'] = null;
      final event = Event.fromJson(validEventJson);

      expect(event.location, equals(<String, double>{}));
    });

    test('should create Event without invites', () {
      validEventJson.remove('invites');
      final event = Event.fromJson(validEventJson);

      expect(event.invites, isNull);
    });

    test('should throw FormatException for invalid JSON structure', () {
      final invalidJson = {
        'id': 'invalid_id', // Should be int
        'title': 'Test Event',
      };

      expect(
        () => Event.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException for missing required fields', () {
      validEventJson.remove('title');

      expect(
        () => Event.fromJson(validEventJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException for invalid date format', () {
      validEventJson['datetimeStart'] = 'invalid-date';

      expect(
        () => Event.fromJson(validEventJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should handle events with different time zones', () {
      validEventJson['datetimeStart'] = '2025-07-15T10:00:00Z';
      validEventJson['datetimeEnd'] = '2025-07-15T12:00:00Z';

      final event = Event.fromJson(validEventJson);

      expect(event.datetimeStart.isUtc, isTrue);
      expect(event.datetimeEnd.isUtc, isTrue);
    });
  });
}
