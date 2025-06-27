import 'dart:math';
import 'package:agenda_app/src/controller/teams_controller.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/view/teams/read_view.dart';
import 'package:flutter/material.dart';
import '../model/user.dart';

class TeamGrid extends StatefulWidget {
  final int maxTeams;
  final TextEditingController? searchController;
  final TeamController? controller;
  final List<Team>? teams;

  const TeamGrid({
    super.key,
    this.maxTeams = 0,
    this.searchController,
    this.controller,
    this.teams,
  });

  @override
  State<StatefulWidget> createState() {
    return _TeamGridState();
  }
}

class _TeamGridState extends State<TeamGrid> {
  late TeamController _controller;
  late TextEditingController? _searchController;
  late List<Team> _teams = [];
  late int _maxTeams;
  late User _user;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    // If the controller is set, use the set controller, else create a new controller
    _controller = widget.controller ?? TeamController();
    _searchController = widget.searchController;
    _searchController?.addListener(_onSearchChanged);
    // _teams = widget.teams ?? _controller.userTeams;
    _maxTeams = widget.maxTeams;
    _getUser();
    // Listens for changes in the teamsList
    _controller.teamsNotifier.addListener(() {
      setState(() {
        isInitialized = true;
        _teams = widget.teams ?? _controller.userTeams;
      });
    });
  }

  void _onSearchChanged() {
    // Rebuild when the input is changed
    setState(() {});
  }

  void _getUser() async {
    _user = await User.fromStorage();
  }

  // Builds a column with the name and description of the team
  Widget _buildNameDescription(BuildContext context, int index, Team team) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          team.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          team.description ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // Builds the gridview with the teams
  Widget _buildGridView(BuildContext context, List<Team> teams) {
    // Get the screen width
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GridView.builder(
      // If the screen is small(mobile) set shrinkwrap to true
      // If shrinkwrap is true it makes the widget the size of the content
        shrinkWrap: screenWidth > 768 ? false : true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // Calculates the aspect ratio based on the dimensions of the screen
          childAspectRatio: 
            screenWidth <= 1024 
            ? screenWidth / (screenHeight / 2.4)
            : screenWidth / (screenHeight / 1.6)
        ),
        // If maxTeams is set it displays the set amount of teams, else display all
        itemCount: _maxTeams != 0 ? min(_maxTeams, teams.length) : teams.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () { showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TeamReadView(team: teams[index], user: _user, controller: _controller,);
                }
            );},
            child: Stack(
                children: [
                  // Fill the card to it's max size
                  Positioned.fill(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        // If the screen is wider than 768 pixels display the widgets next to each other
                        // Else display them underneath each-other
                        child: screenWidth > 768
                            ?Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            teams[index].getIcon(),
                            SizedBox(width: 10),
                            Expanded(
                              child: _buildNameDescription(context, index, teams[index]),
                            ),
                          ],
                        )
                            : Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            teams[index].getIcon(),
                            _buildNameDescription(context, index, teams[index]),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // If the user is owner of the team, display an crown on the card
                  if (_user.id == teams[index].ownerId)
                    Positioned(
                      top: 10,
                      left: 15,
                      child: Text(
                        '👑',
                        // Gold text color because otherwise the web makes a black outline of the crown
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 18,
                        ),
                      ),
                    ),
                ]
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    if(!isInitialized){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    // If the user is not a member of any team, display a message
    if (_teams.isEmpty) {
      return Center(
        child: Text(
          'U bent nog geen beheerder of lid van een team',
            textAlign: TextAlign.center
        )
      );
    }

    // If the searchController is not null, filter the teams based on the search input
    if (_searchController != null) {
      _teams.where((item) =>
          item.name.toLowerCase().contains(
              _searchController?.text.toLowerCase() as Pattern))
          .toList();
    }

    return _buildGridView(context, _teams);
  }
}