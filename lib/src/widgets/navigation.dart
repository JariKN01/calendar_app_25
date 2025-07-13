import 'package:agenda_app/src/view/events/index_view.dart';
import 'package:agenda_app/src/view/home/home_view.dart';
import 'package:agenda_app/src/view/matches/index_view.dart';
import 'package:agenda_app/src/view/teams/index_view.dart';
import 'package:agenda_app/src/model/user.dart';
import 'package:flutter/material.dart';

class TabBarController extends StatefulWidget {
  final TabController tabController;
  final User? user;
  final VoidCallback? onLogout;

  const TabBarController({
    super.key,
    required this.tabController,
    this.user,
    this.onLogout,
  });

  @override
  State<StatefulWidget> createState() {
    return _TabBarControllerState();
  }
}

class _TabBarControllerState extends State<TabBarController> {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController;
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
            // User info header
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      widget.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user?.name ?? 'Gebruiker',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${widget.user?.id ?? 'Onbekend'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profiel'),
              onTap: () {
                Navigator.pop(context);
                _showProfileDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Instellingen'),
              onTap: () {
                Navigator.pop(context);
                _showSettingsDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Uitloggen', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person),
            SizedBox(width: 8),
            Text('Profiel'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gebruikersnaam:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.user?.name ?? 'Onbekend'),
            SizedBox(height: 16),
            Text('Gebruikers ID:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.user?.id.toString() ?? 'Onbekend'),
            SizedBox(height: 16),
            Text('Account type:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Standaard gebruiker'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings),
            SizedBox(width: 8),
            Text('Instellingen'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.palette),
              title: Text('Thema'),
              subtitle: Text('Paars thema actief'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thema-instellingen coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Meldingen'),
              subtitle: Text('Beheer je meldingen'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Melding-instellingen coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('Privacy'),
              subtitle: Text('Privacy-instellingen'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Privacy-instellingen coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Uitloggen'),
          ],
        ),
        content: Text('Weet je zeker dat je wilt uitloggen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuleren'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Uitloggen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User menu button
            if (_tabController.index == 1) // Only show on home tab
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _showUserMenu(context),
                      icon: Icon(Icons.account_circle),
                      iconSize: 32,
                      tooltip: 'Gebruikersmenu',
                    ),
                  ],
                ),
              ),
            TabBar(
              controller: _tabController,
              tabs: const <Widget>[
                Tab(icon: Icon(Icons.calendar_month), text: 'Agenda'),
                Tab(icon: Icon(Icons.home), text: 'Home'),
                Tab(icon: Icon(Icons.sports_soccer), text: 'Matches'),
                Tab(icon: Icon(Icons.people), text: 'Teams'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TabBarViewController extends StatefulWidget {
  final TabController tabController;
  final User? user;

  const TabBarViewController({
    super.key,
    required this.tabController,
    this.user,
  });

  @override
  State<StatefulWidget> createState() {
    return _TabBarViewControllerState();
  }
}

class _TabBarViewControllerState extends State<TabBarViewController>{ 
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController;
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        EventIndex(),
        Home(user: widget.user),
        MatchIndex(),
        TeamIndex(),
      ],
    );
  }
}