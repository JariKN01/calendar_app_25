import 'package:calendar_app/src/model/user.dart';
import 'package:calendar_app/src/view/events/create_view.dart';
import 'package:calendar_app/src/view/matches/create_view.dart';
import 'package:calendar_app/src/widgets/navigation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomeView extends StatelessWidget {
  final User? user; // Name of the logged in user
  final String bannerText;
  final TabController tabController;
  final VoidCallback? onLogout; // Add logout callback

  const HomeView({
    super.key,
    required this.user,
    required this.bannerText,
    required this.tabController,
    this.onLogout,
  });

   Widget _buildQrDialog(BuildContext context) {
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
            Text(
              'Jouw QR Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            if (user != null)
              QrImageView(
                data: user!.id.toString(),
                size: 250,
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(16),
              ),
            SizedBox(height: 20),
            Text(
              'Laat deze code scannen om lid te worden van een team',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Sluiten'),
            ),
          ],
        ),
      ),
    );
  }

  //Builds a FloatingActionButton with content based on the page
  _floatingActionButtonBuilder(BuildContext context, int index){
    final colorScheme = Theme.of(context).colorScheme;

    //Events are on the 0th index of the TabController :)
    if(index == 0){
      return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 5, 5),
        child: FloatingActionButton(
          onPressed: () {
            _showEventCreationMenu(context);
          },
          tooltip: "Nieuw evenement of wedstrijd",
          elevation: 8,
          foregroundColor: colorScheme.onPrimaryContainer,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.add,
            size: 32,
          ),
        ),
      );
    }
    //Teams are on the 3rd index of the TabController (QR code for joining teams)
    else if(index == 3){
      return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 5, 5),
        child: FloatingActionButton(
          onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return _buildQrDialog(context);
                }
            );
          },
          tooltip: "Deelnemen aan een team",
          elevation: 8,
          foregroundColor: colorScheme.onPrimaryContainer,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.qr_code,
            size: 32,
          ),
        ),
      );
    }

    return null;
  }

  void _showEventCreationMenu(BuildContext context) {
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
              'Wat wil je aanmaken?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.event_note, color: Colors.blue),
              title: Text('Evenement'),
              subtitle: Text('Maak een nieuw evenement aan'),
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
              leading: Icon(Icons.sports_soccer, color: Colors.green),
              title: Text('Wedstrijd'),
              subtitle: Text('Organiseer een wedstrijd tussen teams'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return MatchCreation();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: colorScheme.surfaceVariant,
        elevation: 0,
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
            Card(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: colorScheme.primary,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 36,
                      color: colorScheme.onPrimary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Calendar_app',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: TabBarViewController(
                tabController: tabController,
                user: user,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TabBarController(
        tabController: tabController,
        user: user,
        onLogout: onLogout,
      ),
      //Index checked here instead of in _floatingActionButtonBuilder to prevent unintended behaviour
      floatingActionButton: tabController.index != 1 ? _floatingActionButtonBuilder(context, tabController.index) : null,
    );
  }
}