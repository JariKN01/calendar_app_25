import 'package:agenda_app/src/controller/matches_controller.dart';
import 'package:agenda_app/src/controller/teams_controller.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/view/matches/create_view.dart';
import 'package:agenda_app/src/widgets/match_listview.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class MatchIndex extends StatefulWidget{
  const MatchIndex({super.key});

  @override
  State<StatefulWidget> createState(){
    return _MatchIndexState();
  }
}

class _MatchIndexState extends State<MatchIndex>{
  late TeamController teamController;
  late MatchController matchController;
  late MultiSelectController<Team> multiSelectController;
  late List<DropdownItem<Team>> teamsDropdown = [];
  late List<Team> selectedTeams = [];
  late ValueNotifier<int> selectedTeamsNotifier;

  @override
  void initState(){
    super.initState();
    teamController = TeamController();
    matchController = MatchController();
    multiSelectController = MultiSelectController<Team>();
    selectedTeamsNotifier = ValueNotifier(selectedTeams.length);
    teamController.teamsNotifier.addListener((){
      setState((){
        updateListAndTeams();
      });
    });
  }

  updateListAndTeams(){
    addTeamsTolist();
    multiSelectController.setItems(teamsDropdown);
    setSelectedTeams();
  }

  addTeamsTolist(){
    //Clear old teams (if they exist hihi)
    teamsDropdown = [];
    //Add all teams the user is in to the list
    for(Team team in teamController.userTeams){
      teamsDropdown.add(DropdownItem(label: team.name, value: team, selected: true));
    }
  }

  setSelectedTeams(){
    //Clear selected teams
    selectedTeams.clear();
    //Add teams based on multidropdown controller value
    for(DropdownItem item in multiSelectController.selectedItems){
      selectedTeams.add(item.value);
    }
    selectedTeamsNotifier.value = selectedTeams.length;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wedstrijden',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.sports_soccer),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MatchCreation();
                },
              );
            },
            tooltip: 'Nieuwe wedstrijd',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceVariant,
              colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            // Team Selection Card
            Card(
              elevation: 8,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Filter op Teams',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    teamsDropdown.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
                            SizedBox(width: 8),
                            Text(
                              'Geen teams beschikbaar',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                        ),
                        child: MultiDropdown<Team>(
                          items: teamsDropdown,
                          controller: multiSelectController,
                          onSelectionChange: (selectionChanged){setSelectedTeams();},
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Matches List Card
            Expanded(
              child: Card(
                elevation: 8,
                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Alle Wedstrijden',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: selectedTeamsNotifier,
                          builder: (context, value, child){
                            return MatchList(selectedTeams: selectedTeams);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MatchCreation();
            },
          );
        },
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 8,
        child: Icon(Icons.sports_soccer),
        tooltip: 'Nieuwe Wedstrijd',
      ),
    );
  }
}
