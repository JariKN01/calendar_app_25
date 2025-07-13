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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header with close button and title
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, size: 28),
                  tooltip: 'Sluiten',
                ),
                Expanded(
                  child: Text(
                    'Creëer team',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 48), // Balance the close button
              ],
            ),
            SizedBox(height: 20),

            // Form content
            Form(
              child: Column(
                children: [
                  // Icon selector
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
                  SizedBox(height: 20),

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
                  SizedBox(height: 16),

                  // Description input
                  formInput(context, _descriptionController, 'Beschrijving'),
                  SizedBox(height: 20),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Annuleren'),
                      ),
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
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  child: Container(
                                    padding: EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 48,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Succes',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Nieuw team ${newTeam.name} is toegevoegd!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).popUntil(
                                                    (route) => route.isFirst
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Error dialog if the team could not be created
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  child: Container(
                                    padding: EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          color: Theme.of(context).colorScheme.error,
                                          size: 48,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Fout',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Het nieuwe team is niet toegevoegd, probeer het opnieuw!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Creëer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}