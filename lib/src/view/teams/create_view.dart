import 'package:agenda_app/src/controller/teams_controller.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/view/partials.dart';
import 'package:agenda_app/src/view/teams/partials.dart';
import 'package:flutter/material.dart';

class TeamCreateView extends StatefulWidget {
  final TeamController controller;
  const TeamCreateView({
    super.key,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() {
    return _TeamCreateViewState();
  }
}

class _TeamCreateViewState extends State<TeamCreateView> {
  // Default icon is the first icon in the iconMap
  late String iconValue = Team.iconMap.keys.first;
  late final TeamController _controller;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                // Close button, to close the dialog
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close, size: 35),
                ),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
          Text('Creëer team'),
          Expanded(child: SizedBox()),
        ],
      ),
      contentPadding: EdgeInsets.all(20),
      children: [
        Form(
          child: Column(
            children: [
              editableIcon(
                context,
                iconValue,
                // Sets the icon to the new value
                (String newIcon) {
                  setState(() {
                    iconValue = newIcon;
                  });
                }
              ),
              // Spacer
              SizedBox(height: 10),
              // Name input
              formInput(
                context,
                _nameController,
                'Naam',
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Vul de team naam in';
                  }
                  return null;
                },
              ),
              // Spacer
              SizedBox(height: 10),
              // Description input
              formInput(context, _descriptionController, 'Beschrijving'),
              // Spacer
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final Team? newTeam = await _controller.createTeam(
                    _nameController.text,
                    _descriptionController.text,
                    iconValue
                  );

                  if (context.mounted) {
                    if (newTeam != null) {
                      (context as Element).markNeedsBuild();
                      showDialog(
                        context: context,
                        builder: (context) =>
                        AlertDialog(
                          title: Text('Succes'),
                          content: Text(
                            'Nieuw team ${newTeam.name} is toegevoegd!',
                          ),
                          actions: [
                            TextButton(
                              // Close the dialog and go back to the team list
                              onPressed: () {

                                Navigator.of(context).popUntil(
                                        (route) => route.isFirst
                                );
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Error dialog if the team could not be created
                      showDialog(
                        context: context,
                        builder: (context) =>
                        AlertDialog(
                          title: Text('Fout'),
                          content: Text(
                            'Het nieuwe team is niet toegevoegd, probeer het opnieuw!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                child: Text('Creëer'),
              ),
            ],
          )
        ),
      ],
    );
  }
}
