import 'package:agenda_app/src/controller/teams_controller.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/model/user.dart';
import 'package:agenda_app/src/view/partials.dart';
import 'package:agenda_app/src/view/teams/partials.dart';
import 'package:flutter/material.dart';

class TeamUpdateView extends StatefulWidget {
  final Team team;
  final User user;
  final TeamController controller;

  const TeamUpdateView({
    super.key,
    required this.team,
    required this.user,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() {
    return _TeamUpdateViewState();
  }
}

class _TeamUpdateViewState extends State<TeamUpdateView> {
  late Team team;
  late User user;
  late TeamController controller;
  late ValueNotifier<int> membersNotifier;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late String iconValue;

  @override
  void initState() {
    super.initState();
    team = widget.team;
    user = widget.user;
    controller = widget.controller;
    membersNotifier = ValueNotifier(team.members.length);
    // Set the icon value to the team's icon, or the first icon in the map
    iconValue = team.metadata?['icon'] ?? team.metadata?["Icon"] ?? Team.iconMap.keys.first;
    titleController = TextEditingController(text: team.name);
    descriptionController = TextEditingController(text: team.description);
  }

  @override
  Widget build(BuildContext context) {
    // Create a simple dialog with the team data
    return SimpleDialog(
      contentPadding: EdgeInsets.all(20),
      title: teamTitle(context, team, user),
      children: [
        Form(
          child: Column(
           children: [
             // Editable team icon
             editableIcon(
                 context,
                 iconValue, // Sets the icon to the new value
                 (String newIcon) {
                   setState(() {
                     iconValue = newIcon;
                   });
                 }),
             // Edit title
             Padding(
               padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
               child: formInput(context, titleController, "Naam"),
             ),
             // Edit description
             Padding(
               padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
               child: formInput(context, descriptionController, "Beschrijving"),
             ),
             // Save button
             saveTeamButton(
               context,
               controller,
               team,
               titleController,
               descriptionController,
               iconValue
             ),
             divider(context),
           ],
          )
        ),
        // Members list
        ValueListenableBuilder(
          valueListenable: membersNotifier,
          builder: (context, value, child) {
            return membersGrid(context, team, user, membersNotifier, update: true);
          },
        ),
        scanQrButton(context, controller, team),
        SizedBox(height: 7.5),
        deleteTeamButton(context, controller, team),
      ],
    );
  }
}