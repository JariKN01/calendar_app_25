import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/src/model/invite.dart';
import 'package:calendar_app/src/model/team.dart';

void main() {
  group('Invite Model Tests', () {
    late Map<String, dynamic> validInviteJson;
    late Map<String, dynamic> validTeamJson;

    setUp(() {
      validTeamJson = {
        'id': 1,
        'name': 'Test Team',
        'description': 'A test team',
        'ownerId': 1,
        'members': []
      };

      validInviteJson = {
        'id': 1,
        'teamId': 1,
        'matchId': 1,
        'status': 'pending',
        'team': validTeamJson,
      };
    });

    test('should create Invite from valid JSON with all fields', () {
      final invite = Invite.fromJson(validInviteJson);

      expect(invite.id, equals(1));
      expect(invite.teamId, equals(1));
      expect(invite.matchId, equals(1));
      expect(invite.status, equals(Status.pending));
      expect(invite.team, isNotNull);
      expect(invite.team!.name, equals('Test Team'));
    });

    test('should create Invite with null optional fields', () {
      validInviteJson['id'] = null;
      validInviteJson['teamId'] = null;
      validInviteJson['matchId'] = null;

      final invite = Invite.fromJson(validInviteJson);

      expect(invite.id, isNull);
      expect(invite.teamId, isNull);
      expect(invite.matchId, isNull);
      expect(invite.status, equals(Status.pending));
    });

    group('Status Enum Tests', () {
      test('should parse pending status correctly', () {
        validInviteJson['status'] = 'pending';
        final invite = Invite.fromJson(validInviteJson);
        expect(invite.status, equals(Status.pending));
      });

      test('should parse accepted status correctly', () {
        validInviteJson['status'] = 'accepted';
        final invite = Invite.fromJson(validInviteJson);
        expect(invite.status, equals(Status.accepted));
      });

      test('should parse declined status correctly', () {
        validInviteJson['status'] = 'declined';
        final invite = Invite.fromJson(validInviteJson);
        expect(invite.status, equals(Status.declined));
      });

      test('should parse canceled status correctly', () {
        validInviteJson['status'] = 'canceled';
        final invite = Invite.fromJson(validInviteJson);
        expect(invite.status, equals(Status.canceled));
      });

      test('should throw ArgumentError for invalid status', () {
        validInviteJson['status'] = 'invalid_status';

        expect(
          () => Invite.fromJson(validInviteJson),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('getStatus Method Tests', () {
      test('should return correct Dutch text for pending status', () {
        final invite = Invite(status: Status.pending);
        expect(invite.getStatus(), equals('In afwachting'));
      });

      test('should return correct Dutch text for accepted status', () {
        final invite = Invite(status: Status.accepted);
        expect(invite.getStatus(), equals('Geaccepteerd'));
      });

      test('should return correct Dutch text for declined status', () {
        final invite = Invite(status: Status.declined);
        expect(invite.getStatus(), equals('Afgewezen'));
      });

      test('should return correct Dutch text for canceled status', () {
        final invite = Invite(status: Status.canceled);
        expect(invite.getStatus(), equals('Geannuleerd'));
      });
    });

    test('should throw FormatException for invalid JSON structure', () {
      final invalidJson = {
        'id': 'invalid_id', // Should be int or null
        'status': 'pending',
      };

      expect(
        () => Invite.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should create Invite with constructor', () {
      final invite = Invite(
        id: 1,
        teamId: 1,
        matchId: 1,
        status: Status.accepted,
      );

      expect(invite.id, equals(1));
      expect(invite.teamId, equals(1));
      expect(invite.matchId, equals(1));
      expect(invite.status, equals(Status.accepted));
      expect(invite.team, isNull);
    });

    test('should create Invite with only required status field', () {
      final invite = Invite(status: Status.pending);

      expect(invite.id, isNull);
      expect(invite.teamId, isNull);
      expect(invite.matchId, isNull);
      expect(invite.status, equals(Status.pending));
      expect(invite.team, isNull);
    });
  });
}
