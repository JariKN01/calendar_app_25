import 'package:calendar_app/src/controller/teams_controller.dart';
import 'package:calendar_app/src/model/team.dart';
import 'package:calendar_app/src/model/user.dart';
import 'package:calendar_app/src/view/partials.dart';
import 'package:calendar_app/src/view/teams/partials.dart';
import 'package:flutter/material.dart';

class TeamReadView extends StatefulWidget {
  final Team team;
  final User user;
  final TeamController controller;

  const TeamReadView({
    super.key,
    required this.team,
    required this.user,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() {
    return _TeamReadViewState();
  }
}

class _TeamReadViewState extends State<TeamReadView> {
  late Team team;
  late User user;
  late TeamController controller;
  late ValueNotifier<int> membersNotifier;

  @override
  void initState() {
    super.initState();
    team = widget.team;
    user = widget.user;
    controller = widget.controller;
    membersNotifier = ValueNotifier(team.members.length);
  }

  @override
  Widget build(BuildContext context) {
    // Create a simple dialog with the team data
    return SimpleDialog(
      title: teamTitle(context, team, user, controller: controller),
      children: [
        // Team icon
        teamIcon(context, team),
        // Description
        // If the description is not null, display it
        if (team.description != null) ...[
          divider(context),
          teamDescription(context, team),
        ],
        divider(context),
        // Members list
        ValueListenableBuilder(
          valueListenable: membersNotifier,
            builder: (context, value, child) {
              return membersGrid(context, team, user, membersNotifier);
            },
        ),
        // membersGrid(context, team, user),
        // Only show this button if the user is the owner of the team
        if (user.isOwner(team)) scanQrButton(context, controller, team),
      ],
    );
  }
}