import 'dart:math';
import 'package:agenda_app/src/controller/events_controller.dart';
import 'package:agenda_app/src/extensions/datetime.dart';
import 'package:agenda_app/src/model/event.dart';
import 'package:agenda_app/src/view/events/update_view.dart';
import 'package:agenda_app/src/widgets/team_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EventDetails extends StatelessWidget{
  final Event event;
  final EventController controller;

  const EventDetails({
    super.key, 
    required this.event,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      titlePadding: EdgeInsets.fromLTRB(10,8,10,8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 1, 
            child: SizedBox()
          ),
          Text(
            event.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,  
              fontSize: 24,
            ),
          ),
          //Make inkwell with clickable icon
          Expanded(
            flex: 1, 
            child: Align(
              alignment: Alignment.centerRight, 
              child: InkWell(
                onTap: (){
                  showDialog(
                    context: context, 
                    builder: (BuildContext context){
                      return EventUpdate(
                        event: event, 
                        controller: controller
                      );
                    }
                  );
                },
                child: Icon(Icons.edit),
              ),
            ),
          ),
        ],
      ),
      children: [
        //Details
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            color: Colors.white,
          ),
          padding: EdgeInsets.fromLTRB(10,5,10,17.5),
          child: Column(
            children: [
              //Status/StartTime/EndTime
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
                      //Status, get based on invite
                      controller.checkInviteStatus(event),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Starttijd", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(event.datetimeStart.formatDate()),
                      Text(event.datetimeStart.formatHourAndMinutes()),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Eindtijd", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(event.datetimeStart.formatDate()),
                      Text(event.datetimeEnd.formatHourAndMinutes()),
                    ],
                  ),
                ],
              ),
              Divider(),
              Column(
                children: [
                  Text("Deelnemende Teams", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 80, width: 480, child: TeamGrid(teams: [event.team])),
                ],
              ),
              Divider(),
              Column(
                children: [
                  Text("Beschrijving", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(width: 480, child: Text(event.description, textAlign: TextAlign.center)),
                ],
              ),
              Divider(),
              Column(
                children: [
                  Text("Locatie", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  //Cool Map - only show if location exists
                  event.location.isNotEmpty &&
                  event.location.containsKey('latitude') &&
                  event.location.containsKey('longitude') &&
                  event.location['latitude'] != null &&
                  event.location['longitude'] != null
                  ? SizedBox(
                    height: 300,
                    width: 450,
                    child: 
                    Container(
                      decoration: BoxDecoration(border: Border.all(width: 1.25)),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(event.location['latitude']!, event.location['longitude']!),
                          initialZoom: 16.51,
                        ),
                        children: [
                          TileLayer( // Display map tiles from any source
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(event.location['latitude']!, event.location['longitude']!),
                                child: Icon(
                                  Icons.location_pin, 
                                  size: 60, 
                                  color: Colors.red, 
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.75),
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 2.5,
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ),
                        ],
                      ),
                    ),
                  )
                  : Container(
                    height: 100,
                    width: 450,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.25, color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Geen locatie opgegeven',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}