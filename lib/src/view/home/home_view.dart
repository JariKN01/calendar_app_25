import 'package:agenda_app/src/widgets/event_listview.dart';
import 'package:agenda_app/src/widgets/team_gridview.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // Make widgets for building event and team list so they are not duplicated
  Widget _buildEventsList(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: EventList(maxEvents: 4,),
    );
  }

  Widget _buildTeamsList(BuildContext context, int maxTeams) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: TeamGrid(maxTeams: maxTeams),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // If the screen is wider than 768 pixels display the widgets next to each other
    // Else display them underneath each-other
    return screenWidth > 768 // If the app is run on the web, make a row
      ? Row(
          children: [
            Expanded(child: _buildEventsList(context)),
            Expanded(child: _buildTeamsList(context, 16)),
          ],
    )
      : SingleChildScrollView(
          child: Column(
            children: [
              _buildEventsList(context),
              _buildTeamsList(context, 4),
            ],
          ),
    );
  }
}