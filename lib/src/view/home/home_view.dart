import 'package:calendar_app/src/model/user.dart';
import 'package:calendar_app/src/view/events/create_view.dart';
import 'package:calendar_app/src/widgets/event_listview.dart';
import 'package:calendar_app/src/widgets/team_gridview.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final User? user;

  const Home({super.key, this.user});

  // Build a professional user header widget
  Widget _buildUserHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? 'Goedemorgen' :
                     now.hour < 18 ? 'Goedemiddag' : 'Goedenavond';

    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.primaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$timeOfDay, ${user?.name ?? 'Gebruiker'}!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Welkom terug bij je agenda',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${user?.id ?? 'Onbekend'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Quick Actions
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    _showUserMenu(context);
                  },
                  icon: Icon(Icons.settings),
                  iconSize: 28,
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 8),
                IconButton(
                  onPressed: () {
                    _showNotifications(context);
                  },
                  icon: Icon(Icons.notifications),
                  iconSize: 28,
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profiel'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Instellingen'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Uitloggen'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add logout functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Meldingen'),
        content: Text('Geen nieuwe meldingen'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  // Make widgets for building event and team list so they are not duplicated
  Widget _buildEventsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        height: 400, // Fixed height to prevent unbounded constraints
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Aankomende Evenementen',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: EventList(maxEvents: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsList(BuildContext context, int maxTeams) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        height: 400, // Fixed height to prevent unbounded constraints
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.group,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Mijn Teams',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TeamGrid(maxTeams: maxTeams),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Remove AppBar to prevent duplicate bars - main_view.dart handles the top navigation
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
        child: screenWidth > 768 // If the app is run on the web, make a row
          ? Column(
              children: [
                _buildUserHeader(context),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildEventsList(context)),
                      Expanded(child: _buildTeamsList(context, 16)),
                    ],
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  _buildUserHeader(context),
                  _buildEventsList(context),
                  _buildTeamsList(context, 4),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickActions(context);
        },
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 8,
        child: Icon(Icons.add),
        tooltip: 'Snelle acties',
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Snelle Acties',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.event_note),
              title: Text('Nieuw Evenement'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EventCreation();
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group_add),
              title: Text('Nieuw Team'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to teams section where you can create teams
                // Since we don't have a direct team creation dialog,
                // we'll show a message for now
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ga naar de Teams sectie om een nieuw team aan te maken'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}