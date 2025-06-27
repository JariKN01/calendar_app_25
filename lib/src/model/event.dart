import 'package:agenda_app/src/model/invite.dart';
import 'package:agenda_app/src/model/team.dart';
class Event {
  final int id;
  final String title;
  final String description;
  final DateTime datetimeStart;
  final DateTime datetimeEnd;
  final Map<String, double> location;
  final int teamId;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Team team;
  final List<Invite>? invites;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.datetimeStart,
    required this.datetimeEnd,
    required this.location,
    required this.teamId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.team,
    this.invites,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? jsonInvites = json['invites'];
    try {
      return switch (json) {
        {
        'id': int id,
        'title': String title,
        'description': String description,
        'datetimeStart': String datetimeStart,
        'datetimeEnd': String datetimeEnd,
        // 'location': Map<String, double> location,
        'teamId': int teamId,
        'createdBy': int createdBy,
        'createdAt': String createdAt,
        'updatedAt': String updatedAt,
        } =>
            Event(
              id: id,
              title: title,
              description: description,
              datetimeStart: DateTime.parse(datetimeStart),
              datetimeEnd: DateTime.parse(datetimeEnd),
              location: Map<String, double>.from(json['location']), // Apparently I can't do it in the normal way🤷‍♂️
              teamId: teamId,
              createdBy: createdBy,
              createdAt: DateTime.parse(createdAt),
              updatedAt: DateTime.parse(updatedAt),
              team: Team.fromJson(json['team']),
              invites: jsonInvites?.map((invite) => Invite.fromJson(invite)).toList(),
            ),
        _ => throw const FormatException('Failed to load event'),
      };
    } catch (e) {
      // Include the original JSON map in the exception message
      throw FormatException("Failed to load event from JSON: $json. Error: $e");
    }
  }
}