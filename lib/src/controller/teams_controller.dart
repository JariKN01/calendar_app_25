import 'dart:convert';
import 'dart:io';
import 'package:agenda_app/src/constants.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TeamController {
  final ValueNotifier<List<Team>> _teamsNotifier = ValueNotifier([]);
  List<Team> _teams = [];
  List<Team> _userTeams = [];
  late User _user;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  TeamController() {
    _loadTeams();
  }

  ValueNotifier<List<Team>> get teamsNotifier => _teamsNotifier;
  List<Team> get teams => _teams;
  List<Team> get userTeams => _userTeams;
  User get user => _user;

  // Load the user from storage
  Future<void> _loadTeams() async {
    _user = await User.fromStorage();
    await fetchTeams();
    await filterUserTeams();
  }

  // Fetch the teams from the API
  Future<void> fetchTeams() async {
    final String? token = await _storage.read(key: 'token');
    final url = Uri.parse('${Constants.baseApiUrl}/teams');
    List<Team> teams = [];

    try {
      final response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      });

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> data = jsonDecode(response.body)['data'];

        // Checks if the user is a member of the team, and adds the team to the list
        teams = data.map((teamData) => Team.fromJson(teamData)).toList();

        // Sort the teams alphabetically
        teams.sort((a, b) => a.name.compareTo(b.name));

        // Save teams to the list for later use, fe filtering
        _teams = teams;
        teamsNotifier.value = _teams;
      } else {
        throw Exception('Failed to load teams');
      }
    } catch (e) {
      throw Exception('Failed to load teams: $e');
    }
  }

  // Filter the teams the user is a member of
  Future<void> filterUserTeams() async {
    _userTeams = _teams.where((team) {
      return team.members.any((member) => member.id == _user.id);
    }).toList();

    // Sort the teams alphabetically
    _userTeams.sort((a, b) => a.name.compareTo(b.name));

    teamsNotifier.value = _userTeams;
  }

  // Filter the teams based on the query
  List<Team> filterTeams(String query) {
    return _teams
        .where((team) => team.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Add new member to the team
  Future<User?> addMember(Team team, int memberId) async {
    final String? token = await _storage.read(key: 'token');
    final url = Uri.parse('${Constants.baseApiUrl}/teams/${team.id}/addUser');

    try {
      // Try adding the new member to the team
      final response = await http.post(
        url,
        headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode({'userId': memberId}),
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> data = jsonDecode(response.body)['data'];

        // print('-----\nUser added: $data\n-----');

        Team updatedTeam = Team.fromJson(data);
        // Get the new member from the updated team
        User newMember = updatedTeam.members.firstWhere((member) => member.id == memberId);

        // If the newMember was not already in the team, add it to the team
        if (team.members.where((member) => member.id == memberId).isEmpty) {
          team.members.add(newMember);
        }

        return newMember;
      } else {
        throw Exception('Failed to add member to the team');
      }
    } catch (e) {
      throw Exception('Failed to add member to the team: $e');
    }
  }

  // Remove the team
  Future<bool> remove(Team team) async {
    final String? token = await _storage.read(key: 'token');
    final url = Uri.parse('${Constants.baseApiUrl}/teams/${team.id}');

    try {
      // Try adding the new member to the team
      final response = await http.delete(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        // Remove the team from the list
        _teams.removeWhere((t) => t.id == team.id);
        _userTeams.removeWhere((t) => t.id == team.id);

        // Notify the listeners that the team was removed
        _teamsNotifier.value = _teams;

        return true;
      } else {
        throw Exception('Failed to add member to the team');
      }
    } catch (e) {
      throw Exception('Failed to add member to the team: $e');
    }
  }

  // Remove a member from a team
  Future<bool> removeMember(Team team, User member) async {
    final removeUrl = Uri.parse('${Constants.baseApiUrl}/teams/${team.id}/removeUser');

    // If the user is the owner of the team, the user can remove the member
    // For removing the user, the removeUser endpoint is used
    final response = await http.post(
      removeUrl,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${_user.token}',
      },
      body: jsonEncode({'userId': member.id})
    );

    // If the response is OK, remove the member from the team
    // This can't be done underneath the if statement
    // because the response variable is not available :(
    if (response.statusCode == HttpStatus.ok) {
      team.members.remove(member);
      return true;
    }

    // If, for some reason, the response is not OK, return false
    return false;
  }

  // Leave the team
  Future<bool> leaveTeam(Team team, User member) async {
    final leaveUrl = Uri.parse('${Constants.baseApiUrl}/teams/${team.id}/leave');

    final response = await http.post(
      leaveUrl,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${_user.token}',
      },
    );

    // If the response is OK, remove the member from the team
    // This can't be done underneath the if statement
    // because the response variable is not available :(
    if (response.statusCode == HttpStatus.ok) {
      team.members.remove(member);
      return true;
    }
    return false;
  }

  // Create a new team
  Future<Team?> createTeam(String name, String? description, String icon) async {
    final url = Uri.parse('${Constants.baseApiUrl}/teams');
    late Team team;

    final body = jsonEncode({
      'name': name,
      'description': description,
      'metadata': {
        'icon': icon,
      },
    });

    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${_user.token}',
        },
        body: body,
      );

      if (response.statusCode == HttpStatus.created) {
        final dynamic data = jsonDecode(response.body)['data'];

        team = Team.fromJson(data);

        // Add the team to the list of teams
        _teams.add(team);
        _userTeams.add(team);

        // Notify the listeners that a new team was created
        _teamsNotifier.value = _teams;

        return team;
      }
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
    return null;
  }

  // Update the team
  Future<Team?> update(Team team) async {
    final url = Uri.parse('${Constants.baseApiUrl}/teams/${team.id}');
    late Team updatedTeam;

    final body = jsonEncode({
      'name': team.name,
      'description': team.description,
      'metadata': team.metadata,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${_user.token}',
        },
        body: body,
      );

      if (response.statusCode == HttpStatus.ok) {
        final dynamic data = jsonDecode(response.body)['data'];

        updatedTeam = Team.fromJson(data);

        // Update the team in the list of teams
        _teams[_teams.indexOf(team)] = updatedTeam;
        _userTeams[_userTeams.indexOf(team)] = updatedTeam;

        // Notify the listeners that a team was updated
        _teamsNotifier.value = _teams;

        return updatedTeam;
      }
    } catch (e) {
      throw Exception('Failed to update team: $e');
    }
    return null;
  }
}
