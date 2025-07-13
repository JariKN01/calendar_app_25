import 'dart:math';
import 'package:agenda_app/src/controller/events_controller.dart';
import 'package:agenda_app/src/extensions/datetime.dart';
import 'package:agenda_app/src/model/event.dart';
import 'package:agenda_app/src/model/team.dart';
import 'package:agenda_app/src/view/events/read_view.dart';
import 'package:flutter/material.dart';

class EventList extends StatefulWidget {
  final int maxEvents;
  final List<Team>? selectedTeams;

  const EventList({
    super.key,
    this.maxEvents = 0,
    this.selectedTeams
  });

  @override 
  State<StatefulWidget> createState() {
    return _EventListState();
  }
}

class _EventListState extends State<EventList> {
  late EventController _controller;
  late Future<List<Event>> _events;
  late int _maxEvents;
  late List<Team>? _selectedTeams;
  late List<Event> _selectedTeamsEvents;

  @override
  void initState() {
    super.initState();
    _controller = EventController();
    _maxEvents = widget.maxEvents;
    _selectedTeams = widget.selectedTeams;
    _selectedTeamsEvents = [];
    _loadEvents();
  }

  void _loadEvents() {
    _events = _controller.getEventsAndMatches();
  }

  @override
  void didUpdateWidget(EventList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload events when widget updates
    _loadEvents();
  }

  List<Event> getEventsOnSelectedTeams(List<Event> allEvents){
    _selectedTeamsEvents.clear();
    for(Event event in allEvents){
      if(_selectedTeams!.any((team) => team.id == event.teamId)){
        _selectedTeamsEvents.add(event);
      }
    }
    return _selectedTeamsEvents;
  }

  Widget eventCard(Event event, int index) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.fromLTRB(6, 0, 6, 10),
      shape: RoundedRectangleBorder(
        borderRadius: _maxEvents == 0 
        ? BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6))
        : BorderRadius.all(Radius.circular(6)),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Title of the event/match
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // If first element on home (Or other pages where maxEvents is not 0) or if EVENTS HAVE NO LIMIT!!! (on event index)
                  if (index == 0 || _maxEvents == 0)
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  // Formats the data and display it
                  event.datetimeStart.formatDate(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  // Displays the start and end time
                  '${event.datetimeStart.formatHourAndMinutes()} - ${event.datetimeEnd.formatHourAndMinutes()}'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListView(List<Event> events) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _maxEvents != 0 ? min(_maxEvents, events.length) : events.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: (){
            showDialog(
              context: context,
              builder: (BuildContext context){
                //Return Event Read View
                return EventDetails(event: events[index], controller: _controller);
              }
            );
          },
          child: Column(
            children: [
              _maxEvents == 0 ?
              Container(
                margin: EdgeInsets.fromLTRB(6, 0, 6, 0),
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(events[index].team!.name),
                    //Get event status from invite if available
                    _controller.checkInviteStatus(events[index]),
                  ],
                ),
              ) :
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              ),
              eventCard(events[index], index),
            ]
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: _events,
      builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the data is loading, display a spinner
          return Center(child: CircularProgressIndicator());
        } 
        else if (snapshot.hasError) {
          // If there was an error, display the error message
          return Center(child: Text('Error: ${snapshot.error}'));
        } 
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // If there are no events, show a message
          return Center(
              child: Text(
                'U heeft nog geen aankomende evenementen',
                textAlign: TextAlign.center,
              ));
        } 
        else { 
          List<Event> events = snapshot.data!;
          if(_selectedTeams != null){
            events = getEventsOnSelectedTeams(events);
          }
          if(events.isEmpty){
            return Center(child: Text("Geen teams geselecteerd!"));
          }
          // If the data is returned, show the events list
          return buildListView(events);
        }
      },
    );
  }
}
