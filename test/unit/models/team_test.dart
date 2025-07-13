import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/model/user.dart';

void main() {
  group('Team Model Tests', () {
    late Map<String, dynamic> validTeamJson;
    late DateTime testCreatedAt;
    late DateTime testUpdatedAt;

    setUp(() {
      testCreatedAt = DateTime(2025, 7, 1, 9, 0);
      testUpdatedAt = DateTime(2025, 7, 10, 14, 30);

      validTeamJson = {
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
          },
          {
            'id': 2,
            'name': 'Jane Smith',
          }
        ]
      };
    });

    test('should create Team from valid JSON', () {
      final team = Team.fromJson(validTeamJson);

      expect(team.id, equals(1));
      expect(team.name, equals('Development Team'));
      expect(team.description, equals('Software development team'));
      expect(team.ownerId, equals(1));
      expect(team.createdAt, equals(testCreatedAt));
      expect(team.updatedAt, equals(testUpdatedAt));
      expect(team.metadata, equals({'icon': 'work'}));
      expect(team.members.length, equals(2));
      expect(team.members[0].name, equals('John Doe'));
      expect(team.members[1].name, equals('Jane Smith'));
    });

    test('should create Team with null optional fields', () {
      validTeamJson['description'] = null;
      validTeamJson['ownerId'] = null;
      validTeamJson['createdAt'] = null;
      validTeamJson['updatedAt'] = null;
      validTeamJson['metadata'] = null;
      validTeamJson['members'] = null;

      final team = Team.fromJson(validTeamJson);

      expect(team.description, isNull);
      expect(team.ownerId, isNull);
      expect(team.createdAt, isNull);
      expect(team.updatedAt, isNull);
      expect(team.metadata, isNull);
      expect(team.members, isEmpty);
    });

    test('should create Team with empty members list', () {
      validTeamJson['members'] = [];

      final team = Team.fromJson(validTeamJson);

      expect(team.members, isEmpty);
    });

    test('should throw FormatException for invalid JSON', () {
      final invalidJson = {
        'id': 'invalid_id', // Should be int
        'name': 'Test Team',
      };

      expect(
        () => Team.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException for missing required fields', () {
      validTeamJson.remove('name');

      expect(
        () => Team.fromJson(validTeamJson),
        throwsA(isA<FormatException>()),
      );
    });

    group('Team Icon Tests', () {
      test('should return default group icon when no metadata', () {
        final team = Team(
          id: 1,
          name: 'Test Team',
          members: [],
        );

        final icon = team.getIcon();
        expect(icon, isA<Icon>());
      });

      test('should return correct icon from icon map', () {
        final team = Team(
          id: 1,
          name: 'Test Team',
          metadata: {'icon': 'work'},
          members: [],
        );

        final icon = team.getIcon();
        expect(icon, isA<Icon>());
      });

      test('should return network image for URL icon', () {
        final team = Team(
          id: 1,
          name: 'Test Team',
          metadata: {'icon': 'https://example.com/icon.png'},
          members: [],
        );

        final icon = team.getIcon();
        expect(icon, isA<Image>());
      });

      test('should return default icon for unknown icon string', () {
        final team = Team(
          id: 1,
          name: 'Test Team',
          metadata: {'icon': 'unknown_icon'},
          members: [],
        );

        final icon = team.getIcon();
        expect(icon, isA<Icon>());
      });

      test('should handle icon with different case in metadata', () {
        final team = Team(
          id: 1,
          name: 'Test Team',
          metadata: {'Icon': 'sports'}, // Capital I
          members: [],
        );

        final icon = team.getIcon();
        expect(icon, isA<Icon>());
      });

      test('should return icon with custom size', () {
        final team = Team(
          id: 1,
          name: 'Test Team',
          metadata: {'icon': 'work'},
          members: [],
        );

        final icon = team.getIcon(size: 24);
        expect(icon, isA<Icon>());
      });
    });

    group('Team Icon Map Tests', () {
      test('should contain all expected icon mappings', () {
        expect(Team.iconMap['group'], equals(Icons.group));
        expect(Team.iconMap['work'], equals(Icons.work));
        expect(Team.iconMap['family'], equals(Icons.family_restroom));
        expect(Team.iconMap['sports'], equals(Icons.sports_soccer));
        expect(Team.iconMap['church'], equals(Icons.church));
        expect(Team.iconMap['volunteer'], equals(Icons.volunteer_activism));
        expect(Team.iconMap['school'], equals(Icons.school));
        expect(Team.iconMap['music'], equals(Icons.music_note));
        expect(Team.iconMap['gaming'], equals(Icons.videogame_asset));
        expect(Team.iconMap['travel'], equals(Icons.flight));
        expect(Team.iconMap['gym'], equals(Icons.fitness_center));
        expect(Team.iconMap['calendar'], equals(Icons.calendar_month));
      });

      test('should have group as first icon (default)', () {
        expect(Team.iconMap.values.first, equals(Icons.group));
      });
    });
  });
}
