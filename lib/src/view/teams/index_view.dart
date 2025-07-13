import 'package:agenda_app/src/controller/teams_controller.dart';
import 'package:agenda_app/src/view/partials.dart';
import 'package:agenda_app/src/view/teams/create_view.dart';
import 'package:agenda_app/src/widgets/team_gridview.dart';
import 'package:flutter/material.dart';

class TeamIndex extends StatelessWidget {
  const TeamIndex({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final TeamController controller = TeamController();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header section with search and create button
        Container(
          margin: EdgeInsets.all(16),
          child: Row(
            children: [
              // Search bar
              Expanded(
                child: Container(
                  height: 50,
                  child: SearchBar(
                    controller: searchController,
                    hintText: "Zoek team",
                    leading: Icon(Icons.search),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                      colorScheme.surface,
                    ),
                    elevation: WidgetStateProperty.all(2),
                  ),
                ),
              ),
              SizedBox(width: 12),

              // Create team button
              Container(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TeamCreateView(controller: controller);
                      },
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: Text(
                    'Team aanmaken',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main content area
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: TeamGrid(
                    searchController: searchController,
                    controller: controller
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}