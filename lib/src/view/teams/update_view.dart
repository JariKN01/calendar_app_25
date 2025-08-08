import 'package:calendar_app/src/controller/teams_controller.dart';
import 'package:calendar_app/src/model/team.dart';
import 'package:calendar_app/src/model/user.dart';
import 'package:calendar_app/src/view/partials.dart';
import 'package:calendar_app/src/view/teams/partials.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with team title
            Container(
              width: double.infinity,
              child: teamTitle(context, team, user),
            ),
            SizedBox(height: 20),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Edit form section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Form(
                        child: Column(
                          children: [
                            // Editable team icon
                            editableIcon(
                                context,
                                iconValue,
                                    (String newIcon) {
                                  setState(() {
                                    iconValue = newIcon;
                                  });
                                }
                            ),
                            SizedBox(height: 16),

                            // Edit title
                            formInput(context, titleController, "Naam"),
                            SizedBox(height: 16),

                            // Edit description
                            formInput(context, descriptionController, "Beschrijving"),
                            SizedBox(height: 20),

                            // Save button
                            saveTeamButton(
                                context,
                                controller,
                                team,
                                titleController,
                                descriptionController,
                                iconValue
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Members section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Teamleden',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ValueListenableBuilder(
                            valueListenable: membersNotifier,
                            builder: (context, value, child) {
                              return membersGrid(context, team, user, membersNotifier, update: true);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Action buttons section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Scan QR button
                          scanQrButton(context, controller, team),
                          SizedBox(height: 12),

                          // Delete team button
                          deleteTeamButton(context, controller, team),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Close button at bottom
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Sluiten'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}