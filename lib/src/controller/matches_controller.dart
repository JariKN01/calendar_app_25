import 'dart:convert';
import 'dart:io';
import 'package:calendar_app/src/constants.dart';
import 'package:calendar_app/src/model/match.dart';
import 'package:calendar_app/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MatchController {
  final ValueNotifier<List<Match>> matchesNotifier = ValueNotifier([]);
  List<Match> matches = [];
  late User _user;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> _loadUser() async {
    _user = await User.fromStorage();
  }

  MatchController() {
    _loadUser();
  }

  // Get all matches
  Future<List<Match>> getMatches() async {
    final String? token = await _storage.read(key: 'token');
    final url = Uri.parse('${Constants.baseApiUrl}/matches');

    try {
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> matchesData = responseBody['data'];

        List<Match> matchesList = [];

        // Convert JSON data to Match objects
        for (var matchData in matchesData) {
          try {
            Match match = Match.fromJson(matchData);

            // Only add match if it starts after now (future matches)
            if (match.datetimeStart.isAfter(DateTime.now())) {
              matchesList.add(match);
            }
          } catch (e) {
            // Skip invalid matches but continue processing
            print('Error parsing match: $e');
          }
        }

        // Sort matches by start date
        matchesList.sort((a, b) => a.datetimeStart.compareTo(b.datetimeStart));

        return matchesList;
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load matches: $e');
    }
  }

  // Create a new match
  Future<bool> createMatch({
    required String title,
    required String description,
    required DateTime datetimeStart,
    required DateTime datetimeEnd,
    required int teamId,
    Map<String, dynamic>? metadata,
  }) async {
    final String? token = await _storage.read(key: 'token');
    final url = Uri.parse('${Constants.baseApiUrl}/matches');

    final body = jsonEncode({
      'title': title,
      'description': description,
      'datetimeStart': datetimeStart.toIso8601String(),
      'datetimeEnd': datetimeEnd.toIso8601String(),
      'teamId': teamId,
      'metadata': metadata ?? {},
    });

    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == HttpStatus.created) {
        // Match successfully created
        return true;
      } else {
        // Handle different error status codes
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['error']?.join(', ') ?? 'Unknown error';
        throw Exception('Failed to create match: $errorMessage');
      }
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }
}
