import 'dart:convert';
import 'dart:io';
import 'package:agenda_app/src/extensions/datetime.dart';
import 'package:agenda_app/src/model/invite.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../model/event.dart';

class EventController {
  final ValueNotifier<List<Event>> eventsNotifier = ValueNotifier([]);
  List<Event> events = [];
  late User _user;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> _loadUser() async {
    _user = await User.fromStorage();
  }

  EventController(){
    _loadUser();
  }
  
  Future<List<Event>> getEventsAndMatches() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    // Get the token to authenticate against the api
    final String? token = await storage.read(key: 'token');
    final eventUrl = Uri.parse('https://team-management-api.dops.tech/api/v2/events');
    final matchUrl = Uri.parse('https://team-management-api.dops.tech/api/v2/matches');
    dynamic events;
    dynamic matches;
    List<Event> eventsList = [];

    // Try to get the events and matches
    // These API request give only the events/matches the user is apart of
    try {
      events = await http.get(
        eventUrl,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      matches = await http.get(
        matchUrl,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
    } catch (e) {
      // Throw exception
      throw Exception('Failed to load teams: $e');
    }

    if (events.statusCode == HttpStatus.ok && matches.statusCode == HttpStatus.ok) {
      // Decode the response body for events and matches
      final eventsBody = jsonDecode(events.body) as Map<String, dynamic>;
      final List<dynamic> eventsData = eventsBody['data'];

      final matchesBody = jsonDecode(matches.body) as Map<String, dynamic>;
      final List<dynamic> matchesData = matchesBody['data'];

      // Add all the events to the list
      for (var event in eventsData) {
        Event eventFromJson = Event.fromJson(event);

        // Only add event if it starts after now
        if (eventFromJson.datetimeStart.isAfter(DateTime.now())) {
          eventsList.add(eventFromJson);
        }
      }
      // Add all the matches to the list
      for (var match in matchesData) {
        Event matchFromJson = Event.fromJson(match);

        // Only add match if it starts after now
        if (matchFromJson.datetimeStart.isAfter(DateTime.now())) {
          eventsList.add(matchFromJson);
        }
      }

      // Sort the events and matches based on start datetime
      eventsList.sort((a, b) => a.datetimeStart.compareTo(b.datetimeStart));

      return eventsList;
    } else {
      throw Exception('Failed to load teams');
    }
  }

  Text checkInviteStatus(Event event) {
    final User user = _user;
    final List<Invite>? invites = event.invites;

    if(invites != null){
      for(Invite invite in invites){
        if(invite.team != null){
          if(invite.team!.members.any((member) => member.id == user.id)){
            return Text(invite.getStatus());
          }
        }
      }
    }
    return Text("Aankomend");
  }
}