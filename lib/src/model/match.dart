import 'package:agenda_app/src/model/event.dart';
import 'package:agenda_app/src/model/invite.dart';

class Match extends Event {
  final List<Invite> invites;

  Match({
    required super.id,
    required super.title,
    required super.description,
    required super.datetimeStart,
    required super.datetimeEnd,
    required super.location,
    required super.teamId,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required super.team,
    required this.invites,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> invites = json['invites'];
      json.remove('invites');
      // Call the Event's fromJson for common fields
      final Event event = Event.fromJson(json);

      return Match(
        id: event.id,
        title: event.title,
        description: event.description,
        datetimeStart: event.datetimeStart,
        datetimeEnd: event.datetimeEnd,
        location: event.location,
        teamId: event.teamId,
        createdBy: event.createdBy,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
        team: event.team,
        invites: invites.map((invite) => Invite.fromJson(invite)).toList() ?? []
      );
    } catch (e) {
      // Include the original JSON map in the exception message
      throw FormatException("Failed to load match from JSON: $json. Error: $e");
    }
  }

}