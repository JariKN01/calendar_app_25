import 'package:agenda_app/src/view/events/index_view.dart';
import 'package:agenda_app/src/view/home/home_view.dart';
import 'package:agenda_app/src/view/teams/index_view.dart';
import 'package:flutter/material.dart';

class TabBarController extends StatefulWidget {
  final TabController tabController;
  const TabBarController({super.key, required this.tabController});

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

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: const <Widget>[
        Tab(icon: Icon(Icons.calendar_month)),
        Tab(icon: Icon(Icons.home)),
        Tab(icon: Icon(Icons.people)),
      ],
    );
  }
}

class TabBarViewController extends StatefulWidget {
  final TabController tabController;
  const TabBarViewController({super.key, required this.tabController});

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
        Home(),
        TeamIndex(),
      ],
    );
  }
}