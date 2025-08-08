import 'package:calendar_app/src/controller/matches_controller.dart';
import 'package:calendar_app/src/extensions/datetime.dart';
import 'package:calendar_app/src/model/match.dart';
import 'package:calendar_app/src/view/matches/update_view.dart';
import 'package:calendar_app/src/widgets/team_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MatchDetails extends StatelessWidget {
  final Match match;
  final MatchController controller;

  const MatchDetails({
    super.key,
    required this.match,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SimpleDialog(
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      backgroundColor: Colors.green.shade50,
      titlePadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.sports_soccer, color: Colors.green, size: 24),
          Expanded(
            flex: 3,
            child: Text(
              match.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.green.shade700,
              ),
            ),
          ),
          // Edit button
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MatchUpdate(
                    match: match,
                    controller: controller,
                  );
                },
              );
            },
            child: Icon(Icons.edit, color: Colors.green.shade600),
          ),
          SizedBox(width: 8),
          // Delete button
          InkWell(
            onTap: () {
              _showDeleteConfirmation(context);
            },
            child: Icon(Icons.delete, color: Colors.red.shade600),
          ),
        ],
      ),
      children: [
        // Details
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            color: Colors.white,
          ),
          padding: EdgeInsets.fromLTRB(10, 5, 10, 17.5),
          child: Column(
            children: [
              // Match Type indicator
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_soccer, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'WEDSTRIJD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Status/StartTime/EndTime
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        _getMatchStatus(),
                        style: TextStyle(
                          color: _getMatchStatus() == 'Aankomend' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Starttijd", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(match.datetimeStart.formatDate()),
                      Text(match.datetimeStart.formatHourAndMinutes()),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Eindtijd", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(match.datetimeEnd.formatDate()),
                      Text(match.datetimeEnd.formatHourAndMinutes()),
                    ],
                  ),
                ],
              ),
              Divider(),

              // Team information
              Column(
                children: [
                  Text("Deelnemende Teams", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 16),
                  _buildTeamInfo(),
                ],
              ),
              Divider(),

              // Description
              Column(
                children: [
                  Text("Beschrijving", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(width: 480, child: Text(match.description, textAlign: TextAlign.center)),
                ],
              ),
              Divider(),

              // Location section
              Column(
                children: [
                  Text("Locatie", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  // Show map if location exists, otherwise show placeholder
                  match.location.isNotEmpty &&
                  match.location.containsKey('latitude') &&
                  match.location.containsKey('longitude') &&
                  match.location['latitude'] != null &&
                  match.location['longitude'] != null
                      ? SizedBox(
                    height: 300,
                    width: 450,
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(width: 1.25)),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(match.location['latitude']!, match.location['longitude']!),
                          initialZoom: 16.51,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(match.location['latitude']!, match.location['longitude']!),
                                child: Icon(
                                  Icons.location_pin,
                                  size: 60,
                                  color: Colors.green,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.75),
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 2.5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                      : Container(
                    height: 100,
                    width: 450,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.25, color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Geen locatie opgegeven',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamInfo() {
    // Try to extract team info from metadata or title
    String homeTeam = 'Onbekend';
    String awayTeam = 'Onbekend';

    // Parse team names from title if it contains "vs"
    if (match.title.contains(' vs ')) {
      List<String> teams = match.title.split(' vs ');
      if (teams.length == 2) {
        homeTeam = teams[0].trim();
        awayTeam = teams[1].trim();
      }
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          // Home team
          Row(
            children: [
              Icon(Icons.home, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Thuis: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  homeTeam,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // VS indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 12),
          // Away team
          Row(
            children: [
              Icon(Icons.flight_takeoff, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Uit: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  awayTeam,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMatchStatus() {
    final now = DateTime.now();
    if (match.datetimeStart.isAfter(now)) {
      return 'Aankomend';
    } else if (match.datetimeStart.isBefore(now) && match.datetimeEnd.isAfter(now)) {
      return 'Bezig';
    } else {
      return 'Afgelopen';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Wedstrijd verwijderen'),
          ],
        ),
        content: Text('Weet je zeker dat je deze wedstrijd wilt verwijderen?\n\n"${match.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuleren'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation
              Navigator.pop(context); // Close details
              _deleteMatch(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Verwijderen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteMatch(BuildContext context) {
    // TODO: Implement delete functionality in MatchController
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wedstrijd "${match.title}" verwijderd!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
