import 'package:agenda_app/src/model/team.dart';

enum Status {pending, accepted, declined, canceled}

class Invite {
  final int? id;
  final int? teamId;
  final int? matchId;
  final Status status;
  final Team? team;

  Invite({
    this.id,
    this.teamId,
    this.matchId,
    required this.status,
    this.team,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    try {
      return Invite(
        id: json['id'] as int?,
        teamId: json['teamId'] as int?,
        matchId: json['matchId'] as int?,
        status: _statusFromString(json['status'] as String),
        team: Team.fromJson(json['team']) as Team?,
      );
    } catch (e) {
      // Include the original JSON map in the exception message
      throw FormatException("Failed to load event from JSON: $json. Error: $e");
    }
  }

  // Helper method to convert string to Status enum
  static Status _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return Status.pending;
      case 'accepted':
        return Status.accepted;
      case 'declined':
        return Status.declined;
      case 'canceled':
        return Status.canceled;
      default:
        throw ArgumentError('Invalid status: $status');
    }
  }

  String getStatus(){
    switch(status){
      case Status.pending:
        return "In afwachting";
      case Status.accepted:
        return "Geaccepteerd";
      case Status.declined:
        return "Afgewezen";
      case Status.canceled:
        return "Geannuleerd";
      default:
        throw ArgumentError('Status niet beschikbaar');
    }
  }
}