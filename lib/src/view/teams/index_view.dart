import 'package:agenda_app/src/controller/teams_controller.dart';
import 'package:agenda_app/src/view/partials.dart';
import 'package:agenda_app/src/view/teams/create_view.dart';
import 'package:agenda_app/src/widgets/team_gridview.dart';
import 'package:flutter/material.dart';

class TeamIndex extends StatelessWidget{
  const TeamIndex({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final TeamController controller = TeamController();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SizedBox(
                  height: 50,
                  child: SearchBar(
                    controller: searchController,
                    hintText: "Zoek team",
                    leading: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(width: 10,),
              SizedBox(
                height: 50,
                child: TextButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(Size(120, 50)),
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  // Goes to the create team controller/screen
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TeamCreateView(controller: controller,);
                      }
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 24,
                        color: Colors.black,
                      ),
                      Text(
                        'Team aanmaken',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]
          ),
        ),
        Expanded(
          child: defaultContainer(
            context,
            TeamGrid(searchController: searchController, controller: controller),
          ),
        ),
      ],
    );
  }
}