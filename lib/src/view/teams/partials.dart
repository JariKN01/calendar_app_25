import 'package:agenda_app/src/controller/teams_controller.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/model/user.dart';
import 'package:agenda_app/src/extensions/capitalize.dart';
import 'package:agenda_app/src/view/events/create_view.dart';
import 'package:agenda_app/src/view/partials.dart';
import 'package:agenda_app/src/view/teams/update_view.dart';
import 'package:flutter/material.dart';
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

// Widgets for the team create/edit views

// Members list
Widget membersGrid(BuildContext context, Team team, User user,
    ValueNotifier<int> membersNotifier, {bool update = false}) {
  return Column(
    children: [
      // Title
      Text(
        'Leden',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      // Container with the members
      Container(
        margin: EdgeInsets.all(10),
        height: 150,
        width: 600,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15)
        ),
        // This gridview builder builds a grid with all the members
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: team.members.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 2.4,
            crossAxisSpacing: 2,
            maxCrossAxisExtent: 200,
          ),
          itemBuilder: (context, index) {
            final member = team.members[index];
            return Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color:Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(15)
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name.capitalize(),
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    // Show crown next to owner of the team
                    if (member.isOwner(team))
                      Text(
                        '👑',
                        // Gold text color because otherwise the web makes a black outline of the crown
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 18,
                        ),
                      ),
                    // Show leave button conditionally
                    // If the user is owner show the icon next to all members
                    if (user.isOwner(team) && member.id != user.id &&
                        update == true)
                      InkWell(
                        onTap: _removeMemberFromTeam(context, TeamController(), team,
                            member, membersNotifier),
                        child: Icon(
                          Icons.person_remove,
                          color: Colors.red,
                        ),
                      ),
                    // If the user is member show the icon only next to users name
                    if (user.id == member.id && !member.isOwner(team))
                      InkWell(
                        onTap: _leaveTeam(context, TeamController(), team,
                            member, membersNotifier),
                        child: Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    ],
  );
}

// Button to scan a QR code for adding a member to the team
Widget scanQrButton(BuildContext context, TeamController controller, Team team) {
  return _buildButton(
    context,
    label: 'Scan QR code',
    icon: Icons.qr_code_scanner,
    color: Theme.of(context).colorScheme.inversePrimary,
    onPressed: _scanQrCode(context, controller, team),
  );
}

// Button to delete a team
Widget deleteTeamButton(BuildContext context, TeamController controller, Team team) {
  return _buildButton(
    context,
    label: 'Team verwijderen',
    icon: Icons.delete_forever_outlined,
    color: Theme.of(context).colorScheme.errorContainer,
    onPressed: _removeTeam(context, controller, team),
    textColor: Colors.redAccent,
  );
}

Widget saveTeamButton(BuildContext context, TeamController controller, Team team,
  TextEditingController title, TextEditingController description,
  String iconValue) {
  return _buildButton(
    context,
    label: "Save",
    icon: Icons.save,
    color: Theme.of(context).colorScheme.inversePrimary,
    onPressed: _saveTeam(context, controller, team, title, description, iconValue),
  );
}

Widget _buildButton(
    BuildContext context, {
      required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onPressed,
      Color? textColor,
    }) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TextButton.icon(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color),
          minimumSize: WidgetStateProperty.all(Size(200, 50)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: onPressed,
        iconAlignment: IconAlignment.end,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(color: textColor),
        ),
      ),
    ],
  );
}

// Adds a member to the team by scanning a QR code
VoidCallback _scanQrCode(BuildContext context, TeamController controller, Team team) {
  return () async {
    // Tijdelijk uitgeschakeld omdat de barcode scanner package verwijderd is
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) =>
          AlertDialog(
            title: Text('Functionaliteit tijdelijk niet beschikbaar'),
            content: Text('QR-code scannen is momenteel niet beschikbaar.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
      );
    }

    /* Oorspronkelijke code uitgeschakeld:
    // Open the QR code scanner
    String? result = await SimpleBarcodeScanner.scanBarcode(
      context,
      scanType: ScanType.qr,
    );

    if (result != null) {
      // Try to parse the result to an int
      int? memberId = int.tryParse(result);
      User? newMember;

      // If the result was an int, try to add the new member to the team
      if (memberId != null) {
        newMember = await controller.addMember(team, memberId);
      }

      // Show a dialog with the success message
      if (newMember != null && context.mounted) {
        // Rebuild the team dialog to add the new member
        (context as Element).markNeedsBuild();
        showDialog(
          context: context,
          builder: (context) =>
            AlertDialog(
              title: Text('Succes'),
              content: Text(
                'Nieuw lid ${newMember?.name.capitalize()} is toegevoegd aan het team!',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
        );
        // If the new member was not added to the team, show an error dialog
      } else if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) =>
            AlertDialog(
              title: Text('Error'),
              content: Text('Het nieuwe lid kon niet worden toegevoegd aan het team.'),
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
    */
  };
}

VoidCallback _removeTeam(BuildContext context, TeamController controller, Team team) {
  return () async {
    // Confirmation dialog
    bool delete = await showDialog(
      context: context,
      builder: (context) =>
        AlertDialog(
          title: Text('${team.name} verwijderen'),
          content: Text('Weet je zeker dat je dit team wilt verwijderen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Nee'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Ja'),
            ),
          ],
        ),
    );

    if (delete) {
      bool success = await controller.remove(team);

      if (success && context.mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) =>
            AlertDialog(
              title: Text('Succes'),
              content: Text('Het team is succesvol verwijderd.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).popUntil(ModalRoute. withName('/')),
                  child: Text('OK'),
                ),
              ],
            ),
        );
      } else if(context.mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) =>
            AlertDialog(
              title: Text('Error'),
              content: Text('Het team kon niet worden verwijderd.'),
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
  };
}

VoidCallback _removeMemberFromTeam(BuildContext context, TeamController controller,
    Team team, User member, ValueNotifier<int> membersNotifier) {
  return () async {
    // Confirmation dialog
    bool delete = await showDialog(
      context: context,
      builder: (context) =>
      AlertDialog(
        // If the user is the team owner, the title is 'Lid verwijderen'
        // If the user is a member, the title is 'Team verlaten'
        // This is because the owner can remove members, but members can only leave the team
        title: Text('Lid verwijderen'),
        content: Text('Weet je zeker dat je ${member.name.capitalize()} wilt verwijderen uit het team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Nee'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Ja'),
          ),
        ],
      ),
    );

    if (delete) {
      bool success = await controller.removeMember(team, member);

      if (success && context.mounted) {
        // Notifies the change in the length of team members list
        // If this is not done, there will be an list length error because
        // the membersGrid gridview itemCount is not updated
        membersNotifier.value = team.members.length;
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) =>
          AlertDialog(
            title: Text('Succes'),
            content: Text('${member.name.capitalize()} is succesvol verwijderd uit het team.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else if(context.mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) =>
          AlertDialog(
            title: Text('Error'),
            content: Text('${member.name.capitalize()} kon niet worden verwijderd uit het team.'),
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
  };
}

VoidCallback _leaveTeam(BuildContext context, TeamController controller,
  Team team, User member, ValueNotifier<int> membersNotifier) {
  return () async {
    // Confirmation dialog
    bool delete = await showDialog(
      context: context,
      builder: (context) =>
      AlertDialog(
        // If the user is the team owner, the title is 'Lid verwijderen'
        // If the user is a member, the title is 'Team verlaten'
        // This is because the owner can remove members, but members can only leave the team
        title: Text('Team verlaten'),
        content: Text('Weet je zeker dat je het team wilt verlaten?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Nee'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Ja'),
          ),
        ],
      ),
    );

    if(delete) {
      // Tries to leave the team
      bool success = await controller.leaveTeam(team, member);

      if (success && context.mounted) {
        // Notifies the change in the length of team members list
        // If this is not done, there will be an list length error because
        // the membersGrid gridview itemCount is not updated
        membersNotifier.value = team.members.length;
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Succes'),
                content: Text('U hebt het team verlaten.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).popUntil(ModalRoute.withName('/')),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      } else if(context.mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) =>
          AlertDialog(
            title: Text('Error'),
            content: Text('U kon niet worden verwijderd uit het team.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).popUntil(ModalRoute.withName('/')),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  };
}

VoidCallback _saveTeam(BuildContext context, TeamController controller, Team team,
  TextEditingController title, TextEditingController description, String iconValue) {
  return () async {
    // Update the team with the new values
    team.name = title.text;
    team.description = description.text;
    team.metadata = {'icon': iconValue};

    // Try to update the team
    Team? newTeam = await controller.update(team);

    if (newTeam != null && context.mounted) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) =>
          AlertDialog(
            title: Text('Succes'),
            content: Text('${newTeam.name} is succesvol bijgewerkt.'),
            actions: [
              TextButton(
                // Close the dialog and go back to the team list
                onPressed: () => Navigator.of(context).popUntil(ModalRoute.withName('/')),
                child: Text('OK'),
              ),
            ],
          ),
      );
    } else if(context.mounted) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) =>
          AlertDialog(
            title: Text('Error'),
            content: Text('${team.name} kon niet worden bijgewerkt.'),
            actions: [
              TextButton(
                // Close the dialog and go back to the team list
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
      );
    }
  };
}

// The team icon
Widget teamIcon(BuildContext context, Team team) {
  return CircleAvatar(
    radius: 70,
    child: team.getIcon(size: 96),
  );
}

// Description of the team
Widget teamDescription(BuildContext context, Team team) {
  return Column(
    children: [
      Text(
        'Beschrijving',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      Text(
        team.description ?? '',
        textAlign: TextAlign.center,
      ),
    ],
  );
}

// Title of the team
Widget teamTitle(BuildContext context, Team team, User user,
    {TeamController? controller}) {
  return Row(
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
      Text(team.name),
      Expanded(
        child: Row(
          children: [
            Expanded(child: SizedBox()),
            // Only show action buttons if the user is the owner of the team
            if (user.isOwner(team)) ...[
              // Button to add event for this team
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return EventCreation();
                      }
                  );
                },
                child: Icon(Icons.add, size: 35),
              ),
              // Only show the edit button if the controller is not null
              // In the create view, the controller is null so the edit button is not shown
              if (controller != null) ...[
                SizedBox(width: 5),
                // Button to edit team
                InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return TeamUpdateView(
                            team: team,
                            user: user,
                            controller: controller,
                          );
                        }
                    );
                  },
                  child: Icon(Icons.edit_square, size: 25),
                ),
              ],
            ],
          ]
        ),
      ),
    ],
  );
}

// Editable icon
Widget editableIcon(BuildContext context, String iconValue,
    Function(String) onIconChanged) {
  TextEditingController imageUriController = TextEditingController();
  // If the icon is not in the icon map, set the URL field to the icon value
  if (!Team.iconMap.containsKey(iconValue)) {
    imageUriController.text = iconValue;
  }
  double iconSize = 96;
  return InkWell(
    // Open the icon picker and assign the selected icon to var icon
    onTap: () async {
      String? newIcon = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return iconPicker(context, imageUriController);
          }
      );
      // Update the icon so it shows the selected icon on the create dialog
      if (newIcon != null) {
        onIconChanged(newIcon);
      }
    },
    child: Stack(
      children: [
        CircleAvatar(
          radius: 70,
          // Check if the icon is a URL or a default icon
          child: Team.iconMap.containsKey(iconValue)
            ? Icon(Team.iconMap[iconValue], size: iconSize)
            : Image.network(
              iconValue,
              width: iconSize,
              height: iconSize,
              // If the url isn't a valid url, show the broken image icon
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.broken_image, size: iconSize
              ),
            ),
        ),
        // Puts a edit icon in the bottom right corner
        Positioned(
          bottom: 5,
          right: 5,
          child: Icon(Icons.edit_square, size: 24),
        ),
      ],
    ),
  );
}

// Icon picker dialog
Widget iconPicker(BuildContext context, TextEditingController imageUriController) {
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
        Text('Kies een icoon'),
        Expanded(child: SizedBox()),
      ],
    ),
    children: [
      Wrap(
        runSpacing: 10, // Space between the rows
        alignment: WrapAlignment.center, // Center-align the icons
        children: Team.iconMap.entries.map((icon) {
          return SizedBox(
            // Calculate the width of the icon based on the screen width
            // 130 is the padding of the dialog, 3 icons per row
            width: (MediaQuery.of(context).size.width - 130) / 3,
            child: InkWell(
              onTap: () {
                // Handle the icon selection
                Navigator.pop(context, icon.key); // Return the selected key
              },
              child: Icon(icon.value, size: 48),
            ),
          );
        }).toList(),
      ),
      // Input field for custom image URL
      Padding(
        // No padding on the bottom
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            formInput(context, imageUriController, "URL"),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context, imageUriController.text);
              },
              child: Text("Enter")
            )
          ],
        )
      ),
    ],
  );
}