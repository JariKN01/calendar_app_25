import 'package:agenda_app/src/model/team.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  final int id;
  final String name;
  final String? token;

  User({
    required this.id,
    required this.name,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return switch (json) {
        {
        'id': int id,
        'name': String name,
        } =>
            User(
              id: id,
              name: name,
              // Token is like this because it is not required
              token: json['token'],
            ),
        _ => throw const FormatException('Failed to load user.'),
      };
    } catch (e) {
    // Include the original JSON map in the exception message
    throw FormatException("Failed to load user from JSON: $json. Error: $e");
    }
  }

  static Future<User> fromStorage() async {
    FlutterSecureStorage storage = FlutterSecureStorage();

    String? storageId = await storage.read(key: 'id');
    String? storageName = await storage.read(key: 'name');
    String? storageToken = await storage.read(key: 'token');

    final id = int.parse(storageId!);

    return User(
      id: id,
      name: storageName ?? '',
      token: storageToken,
    );
  }

  // Checks if the user is owner of team
  bool isOwner(Team team) {
    return id == team.ownerId;
  }
}