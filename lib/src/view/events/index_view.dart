import 'package:agenda_app/src/controller/teams_controller.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/widgets/event_listview.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class EventIndex extends StatefulWidget{
  const EventIndex({super.key});

  @override
  State<StatefulWidget> createState(){
    return _EventIndexState();
  }
}

class _EventIndexState extends State<EventIndex>{
  late TeamController teamController;
  late MultiSelectController<Team> multiSelectController;
  late List<DropdownItem<Team>> teamsDropdown = [];
  late List<Team> selectedTeams = [];
  late ValueNotifier<int> selectedTeamsNotifier;

  @override
  void initState(){
    super.initState();
    teamController = TeamController();
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
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: 
          //Check if teamsDropdown is initialized
          teamsDropdown.isEmpty 
          //Prevents the Multidropdown from being built before the list is properly initialized
          ? Text('No teams available')
          : MultiDropdown<Team>(
            items: teamsDropdown,
            controller: multiSelectController,
            onSelectionChange: (selectionChanged){setSelectedTeams();},
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(10),
            child: ValueListenableBuilder(
              valueListenable: selectedTeamsNotifier, 
              builder: (context, value, child){
                return EventList(selectedTeams: selectedTeams);
              },
            ), 
          ),
        ),
      ],
    ); 
  }
}