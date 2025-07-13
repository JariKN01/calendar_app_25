import 'dart:math';
import 'package:agenda_app/src/controller/teams_controller.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/view/teams/read_view.dart';
import 'package:flutter/material.dart';
import '../model/user.dart';

class TeamGrid extends StatefulWidget {
  final int maxTeams;
  final TextEditingController? searchController;
  final TeamController? controller;
  final List<Team>? teams;

  const TeamGrid({
    super.key,
    this.maxTeams = 0,
    this.searchController,
    this.controller,
    this.teams,
  });

  @override
  State<StatefulWidget> createState() {
    return _TeamGridState();
  }
}

class _TeamGridState extends State<TeamGrid> {
  late TeamController _controller;
  late TextEditingController? _searchController;
  late List<Team> _teams = [];
  late int _maxTeams;
  late User _user;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TeamController();
    _searchController = widget.searchController;
    _searchController?.addListener(_onSearchChanged);
    _maxTeams = widget.maxTeams;
    _getUser();

    // Always try to get user teams when widget is initialized
    if (widget.teams == null) {
      _controller.getUserTeams();
    } else {
      // If teams are provided via widget, use them immediately
      setState(() {
        _teams = widget.teams!;
        isInitialized = true;
      });
    }

    _controller.teamsNotifier.addListener(_teamsListener);
  }

  void _teamsListener() {
    if (mounted) {
      setState(() {
        isInitialized = true;
        _teams = widget.teams ?? _controller.userTeams;
      });
    }
  }

  @override
  void dispose() {
    _searchController?.removeListener(_onSearchChanged);
    _controller.teamsNotifier.removeListener(_teamsListener);
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _getUser() async {
    _user = await User.fromStorage();
  }

  Widget _buildNameDescription(BuildContext context, int index, Team team) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          team.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          team.description ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(BuildContext context, List<Team> teams) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: screenWidth <= 1024
            ? screenWidth / (screenHeight / 2.4)
            : screenWidth / (screenHeight / 1.6),
      ),
      itemCount: _maxTeams != 0 ? min(_maxTeams, teams.length) : teams.length,
      itemBuilder: (context, index) {
        return Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TeamReadView(
                    team: teams[index],
                    user: _user,
                    controller: _controller,
                  );
                },
              );
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: screenWidth > 768
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        teams[index].getIcon(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNameDescription(context, index, teams[index]),
                        ),
                      ],
                    )
                        : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        teams[index].getIcon(),
                        const SizedBox(height: 8),
                        _buildNameDescription(context, index, teams[index]),
                      ],
                    ),
                  ),
                ),
                if (_user.id == teams[index].ownerId)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '👑',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (_teams.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group_off_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'U bent nog geen beheerder of lid van een team',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    List<Team> filteredTeams = _teams;
    if (_searchController != null && _searchController!.text.isNotEmpty) {
      filteredTeams = _teams
          .where((item) => item.name
          .toLowerCase()
          .contains(_searchController!.text.toLowerCase()))
          .toList();
    }

    return _buildGridView(context, filteredTeams);
  }
}