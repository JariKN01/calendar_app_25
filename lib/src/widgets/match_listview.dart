import 'dart:math';
import 'package:agenda_app/src/controller/matches_controller.dart';
import 'package:agenda_app/src/extensions/datetime.dart';
import 'package:agenda_app/src/model/match.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/view/matches/read_view.dart';
import 'package:flutter/material.dart';

class MatchList extends StatefulWidget {
  final int maxMatches;
  final List<Team>? selectedTeams;

  const MatchList({
    super.key,
    this.maxMatches = 0,
    this.selectedTeams
  });

  @override
  State<StatefulWidget> createState() {
    return _MatchListState();
  }
}

class _MatchListState extends State<MatchList> {
  late MatchController _controller;
  late Future<List<Match>> _matches;
  late int _maxMatches;
  late List<Team>? _selectedTeams;
  late List<Match> _selectedTeamsMatches;

  @override
  void initState() {
    super.initState();
    _controller = MatchController();
    _maxMatches = widget.maxMatches;
    _selectedTeams = widget.selectedTeams;
    _selectedTeamsMatches = [];
    _loadMatches();
  }

  void _loadMatches() {
    _matches = _controller.getMatches();
  }

  @override
  void didUpdateWidget(MatchList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadMatches();
  }

  List<Match> getMatchesOnSelectedTeams(List<Match> allMatches){
    _selectedTeamsMatches.clear();
    for(Match match in allMatches){
      if(_selectedTeams!.any((team) => team.id == match.teamId)){
        _selectedTeamsMatches.add(match);
      }
    }
    return _selectedTeamsMatches;
  }

  Widget matchCard(Match match, int index) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.fromLTRB(6, 0, 6, 10),
      shape: RoundedRectangleBorder(
        borderRadius: _maxMatches == 0
        ? BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6))
        : BorderRadius.all(Radius.circular(6)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              // Match indicator
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.sports_soccer,
                  color: Colors.green,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    if (index == 0 || _maxMatches == 0)
                      Text(
                        match.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    match.datetimeStart.formatDate(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${match.datetimeStart.formatHourAndMinutes()} - ${match.datetimeEnd.formatHourAndMinutes()}'
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListView(List<Match> matches) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _maxMatches != 0 ? min(_maxMatches, matches.length) : matches.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: (){
            showDialog(
              context: context,
              builder: (context) => MatchDetails(
                match: matches[index],
                controller: _controller,
              ),
            );
          },
          child: Column(
            children: [
              _maxMatches == 0 ?
              Container(
                margin: EdgeInsets.fromLTRB(6, 0, 6, 0),
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                  color: Colors.green.shade100,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sports_soccer, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          matches[index].team.name,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    Text(
                      'WEDSTRIJD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ) :
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              ),
              matchCard(matches[index], index),
            ]
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Match>>(
      future: _matches,
      builder: (BuildContext context, AsyncSnapshot<List<Match>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nog geen wedstrijden gepland',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ));
        }
        else {
          List<Match> matches = snapshot.data!;
          if(_selectedTeams != null){
            matches = getMatchesOnSelectedTeams(matches);
          }
          if(matches.isEmpty){
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Geen wedstrijden voor geselecteerde teams",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          return buildListView(matches);
        }
      },
    );
  }
}
