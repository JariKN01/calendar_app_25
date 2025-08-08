import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/src/model/user.dart';

void main() {
  group('User Model Tests', () {
    late Map<String, dynamic> validUserJson;

    setUp(() {
      validUserJson = {
        'id': 1,
        'name': 'John Doe',
        'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      };
    });

    test('should create User from valid JSON with token', () {
      final user = User.fromJson(validUserJson);

      expect(user.id, equals(1));
      expect(user.name, equals('John Doe'));
      expect(user.token, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'));
    });

    test('should create User from valid JSON without token', () {
      validUserJson.remove('token');
      final user = User.fromJson(validUserJson);

      expect(user.id, equals(1));
      expect(user.name, equals('John Doe'));
      expect(user.token, isNull);
    });

    test('should create User with null token', () {
      validUserJson['token'] = null;
      final user = User.fromJson(validUserJson);

      expect(user.id, equals(1));
      expect(user.name, equals('John Doe'));
      expect(user.token, isNull);
    });

    test('should throw FormatException for invalid JSON structure', () {
      final invalidJson = {
        'id': 'invalid_id', // Should be int
        'name': 'Test User',
      };

      expect(
        () => User.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException for missing required id field', () {
      validUserJson.remove('id');

      expect(
        () => User.fromJson(validUserJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException for missing required name field', () {
      validUserJson.remove('name');

      expect(
        () => User.fromJson(validUserJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should handle empty name', () {
      validUserJson['name'] = '';
      final user = User.fromJson(validUserJson);

      expect(user.name, equals(''));
    });

    test('should handle different data types for id', () {
      validUserJson['id'] = '1'; // String instead of int

      expect(
        () => User.fromJson(validUserJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should create User with constructor', () {
      final user = User(
        id: 1,
        name: 'Test User',
        token: 'test_token',
      );

      expect(user.id, equals(1));
      expect(user.name, equals('Test User'));
      expect(user.token, equals('test_token'));
    });

    test('should create User without optional token in constructor', () {
      final user = User(
        id: 1,
        name: 'Test User',
      );

      expect(user.id, equals(1));
      expect(user.name, equals('Test User'));
      expect(user.token, isNull);
    });
  });
}
