import 'package:agenda_app/src/model/user.dart';
import 'package:agenda_app/src/view/events/create_view.dart';
import 'package:agenda_app/src/widgets/navigation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomeView extends StatelessWidget {
  final User? user; // Name of the logged in user
  final String bannerText;
  final TabController tabController;
  const HomeView({
    super.key,
    required this.user,
    required this.bannerText,
    required this.tabController,
  });

   Widget _buildQrDialog() {
    return Dialog(
        insetPadding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: user!.id.toString(),
              size: 350,
            ),
            SizedBox(height: 10),
            Text(
              'Laat deze code scannen om lid te worden van een team',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
          ],
        )
    );
  }

  //Builds a FloatingActionButton with content based on the page
  _floatingActionButtonBuilder(BuildContext context, int index){
    late String toolTip;
    late Widget widget;
    late IconData icon;

    //Events are on the 0st index of the TabController :)
    if(index == 0){
      //Event values
      toolTip = "Creeër een evenement";
      widget = EventCreation();
      icon = Icons.add;
    }
    //Teams are on the 2st index of the TabController :))
    else if(index == 2){
      //Team Values
      toolTip = "Deelnemen aan een team";
      widget = _buildQrDialog();
      icon = Icons.qr_code;
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 5, 5),
      child: FloatingActionButton(
        onPressed: (){
          showDialog(
              context: context,
              builder: (BuildContext context){
                return widget;
              }
          );
        },
        tooltip: toolTip,

        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Color(0xFFFFFFFF),
        child: Icon(
          icon,
          size: 36,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: FractionallySizedBox( // Makes the banner 100% width
                widthFactor: 1,
                child: Align( // Aligns the text to the left
                  alignment: Alignment.centerLeft,
                  child: FittedBox( // Makes the text scale down if the name is too long
                    fit: BoxFit.scaleDown,
                    child: Text(
                      bannerText,
                      style: TextStyle(
                        fontSize: 25
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: TabBarViewController(tabController: tabController),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TabBarController(tabController: tabController),
      //Index checked here instead of in _floatingActionButtonBuilder to prevent unintended behaviour
      floatingActionButton: tabController.index != 1 ? _floatingActionButtonBuilder(context, tabController.index) : Text(''),
    );
  }
}